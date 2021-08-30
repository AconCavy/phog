import Foundation
import RealityKit
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {
    static let defaultFilename = "modelFile"

    @Published var logger = LogConsole()
    @Published var input: URL?
    @Published var output: URL?
    @Published var filename: String = defaultFilename
    @Published var fileExtension = FileExtension.usdz
    @Published var sampleOrdering = SampleOrdering.unordered
    @Published var featureSensitivity = FeatureSensitivity.normal
    @Published var detail = Detail.medium
    @Published var isProcessing = false
    @Published var isCancelling = false
    @Published var progress: Double = 0

    private var session: PhotogrammetrySession?

    func runGeneration() {
        let model: PhotogrammetryModel
        do {
            model = try makeModel()
        } catch OptionError.invalidInput {
            logger.error("The input is invalid. Please check the input.")
            return
        } catch OptionError.invalidOutput {
            logger.error("The output is invalid. Please check the output.")
            return
        } catch OptionError.invalidFilename {
            logger.error("The filename is invalid. Please check the filename.")
            return
        } catch {
            logger.error("Unknown error. Please check parameters.")
            return
        }

        let session: PhotogrammetrySession

        do {
            session = try model.makeSession()
        } catch {
            logger.error("Failed to make session. Please check the minumum execution environment")
            return
        }

        logger.log("Start to processing...")
        self.isProcessing = true
        self.session = session
        let handleSessionOutputsTask = Task { await handleSessionOutputs(session) }
        let request = model.makeRequest()
        logger.log("Using request \(String(describing: request))")

        withExtendedLifetime((session, handleSessionOutputsTask)) {
            do {
                try session.process(requests: [request])
            } catch {
                logger.error(String(describing: error))
            }
        }
    }

    func cancelGeneration() {
        guard !self.isCancelling, let session = self.session, session.isProcessing else {
            return
        }

        logger.log("Cancel to processing...")
        self.isCancelling = true
        session.cancel()
    }

    private func makeModel() throws -> PhotogrammetryModel {
        guard let input = input else {
            throw OptionError.invalidInput
        }

        guard let output = output else {
            throw OptionError.invalidOutput
        }

        let filename = filename.isEmpty ? ContentViewModel.defaultFilename : filename

        return try PhotogrammetryModel(
            input: input, output: output, filename: filename, fileExtension: fileExtension,
            sampleOrdering: sampleOrdering, featureSensitivity: featureSensitivity, detail: detail)
    }

    nonisolated private func handleSessionOutputs(_ session: PhotogrammetrySession) async {
        do {
            for try await output in session.outputs {
                await MainActor.run {
                    switch output {
                    case .inputComplete:
                        handleInputComplete()
                    case .requestError(let request, let error):
                        handleRequestError(request: request, error: error)
                    case .requestComplete(let request, let result):
                        handleRequestComplete(request: request, result: result)
                    case .requestProgress(let request, let fractionComplete):
                        handleRequestProgress(request: request, fractionComplete: fractionComplete)
                    case .processingComplete:
                        handleProcessingComplete()
                    case .processingCancelled:
                        handleProcessingCancelled()
                    case .invalidSample(let id, let reason):
                        handleInvalidSample(id: id, reason: reason)
                    case .skippedSample(let id):
                        handleSkippedSample(id: id)
                    case .automaticDownsampling:
                        handleAutomaticDownsampling()
                    @unknown default:
                        logger.error("Unhandled message: \(output.localizedDescription)")
                    }
                }
            }
        } catch {
            await MainActor.run {
                logger.error(String(describing: error))
            }
        }
    }

    private func handleInputComplete() {
        logger.log("Data ingestion is completed. Beginning processing...")
    }

    private func handleRequestError(request: PhotogrammetrySession.Request, error: Error) {
        logger.error(
            "Request \(String(describing: request)) had an error: \(String(describing: error))")
    }

    private func handleRequestComplete(
        request: PhotogrammetrySession.Request, result: PhotogrammetrySession.Result
    ) {
        logger.log("Request complete: \(String(describing: request)) with result...")
        switch result {
        case .modelFile(let url):
            logger.log("modelFile available at url=\(url)")
        default:
            logger.warning("Unexpected result, \(String(describing: result))")
        }
    }

    private func handleRequestProgress(
        request: PhotogrammetrySession.Request, fractionComplete: Double
    ) {
        self.progress = fractionComplete
    }

    private func handleProcessingComplete() {
        logger.log("Processing was completed.")
        resetStatus()
    }

    private func handleProcessingCancelled() {
        logger.warning("Processing was cancelled.")
        resetStatus()
    }

    private func handleInvalidSample(id: Int, reason: String) {
        logger.warning("Sample id=\(id) is invalid. \(String(describing: reason))")
    }

    private func handleSkippedSample(id: Int) {
        logger.warning("Sample id=\(id) was skipped by processing.")
    }

    private func handleAutomaticDownsampling() {
        logger.warning("Automatic downsampling was applied.")
    }

    private func resetStatus() {
        self.isProcessing = false
        self.isCancelling = false
        self.progress = 0
    }
}
