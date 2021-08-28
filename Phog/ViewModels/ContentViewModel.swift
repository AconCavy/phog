import Foundation
import RealityKit
import SwiftUI

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

    var session: PhotogrammetrySession?

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
        let task = makeSessionTask(session: session)
        withExtendedLifetime((session, task)) {
            do {
                let request = model.makeRequest()
                logger.log("Using request \(String(describing: request))")
                try session.process(requests: [request])
            } catch {
                logger.error(String(describing: error))
            }
        }
    }

    func cancelGeneration() {
        guard !isCancelling else {
            return
        }

        guard let session = session, session.isProcessing else {
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

    private func makeSessionTask(session: PhotogrammetrySession) -> Task<Void, Never> {
        return Task {
            do {
                for try await output in session.outputs {
                    await MainActor.run {
                        switch output {
                        case .processingComplete:
                            logger.log("Processing was completed!")
                            resetStatus()
                        case .requestError(let request, let error):
                            logger.error("Request \(String(describing: request)) had an error: \(String(describing: error))")
                        case .requestComplete(let request, let result):
                            handleRequestComplete(request: request, result: result)
                        case .requestProgress(let request, let fractionComplete):
                            handleRequestProgress(request: request, fractionComplete: fractionComplete)
                        case .inputComplete:
                            logger.log("Data ingestion is completed. Beginning processing...")
                        case .invalidSample(let id, let reason):
                            logger.warning("Invalid Sample! id=\(id) reason=\"\(reason)\"")
                        case .skippedSample(let id):
                            logger.warning("Sample id=\(id) was skipped by processing.")
                        case .automaticDownsampling:
                            logger.warning("Automatic downsampling was applied!")
                        case .processingCancelled:
                            logger.warning("Processing was cancelled.")
                            resetStatus()
                        @unknown default:
                            logger.error("Unhandled message: \(output.localizedDescription)")
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    logger.error(String(describing: error))
                    resetStatus()
                }
            }
        }
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

    private func resetStatus() {
        self.isProcessing = false
        self.isCancelling = false
        self.progress = 0
    }
}
