import Foundation
import RealityKit
import SwiftUI

class ContentViewModel: ObservableObject {
    static let defaultFilename = "modelFile"

    @Published var logger: Logger = Logger()
    @Published var input: String = ""
    @Published var output: String = ""
    @Published var filename: String = defaultFilename
    @Published var fileExtension = FileExtension.usdz
    @Published var sampleOrdering = SampleOrdering.none
    @Published var featureSensitivity = FeatureSensitivity.none
    @Published var detail = Detail.medium
    @Published var isProcessing = false
    @Published var progress: Double = 0

    func generatePhotogrammetry() {
        let model = makeModel()

        var maybeSession: PhotogrammetrySession? = nil
        var maybeRequest: PhotogrammetrySession.Request? = nil

        do {
            maybeSession = try model.makeSession()
            maybeRequest = try model.makeRequest()
        } catch OptionError.invalidInput {
            logger.error("Error: The input is invalid. Please check the input.")
            return
        } catch OptionError.invalidOutput {
            logger.error("Error: The output is invalid. Please check the output.")
            return
        } catch OptionError.invalidFilename {
            logger.error("Error: The filename is invalid. Please check the filename.")
            return
        } catch {
            logger.error("Error: Failed to make a session and request")
            return
        }

        guard let session = maybeSession else {
            logger.error(
                "Error: Failed to make session. Please check the minumum execution environment")
            return
        }

        guard let request = maybeRequest else {
            logger.error("Error: Failed to make request. Please check the options")
            return
        }

        let task = makeSessionTask(session: session)
        withExtendedLifetime((session, task)) {
            do {
                logger.log("Log: Using request \(String(describing: request))")
                isProcessing = true
                try session.process(requests: [request])
            } catch {
                logger.error("Error: \(String(describing: error))")
            }
        }
    }

    private func makeModel() -> PhotogrammetryModel {
        let input = input.isEmpty ? nil : input
        let output = output.isEmpty ? nil : output
        let filename = filename.isEmpty ? ContentViewModel.defaultFilename : filename
        let fileExtension = fileExtension.rawValue

        return PhotogrammetryModel(
            input: input, output: output, filename: filename, fileExtension: fileExtension,
            sampleOrdering: sampleOrdering.map(), featureSensitivity: featureSensitivity.map(),
            detail: detail.map())
    }

    private func makeSessionTask(session: PhotogrammetrySession) -> Task<Void, Never> {
        return Task {
            do {
                for try await output in session.outputs {
                    switch output {
                    case .processingComplete:
                        logger.log("Log: Processing was completed!")
                        isProcessing = false
                    case .requestError(let request, let error):
                        logger.error("Error: Request \(String(describing: request)) had an error: \(String(describing: error))")
                    case .requestComplete(let request, let result):
                        handleRequestComplete(request: request, result: result)
                    case .requestProgress(let request, let fractionComplete):
                        handleRequestProgress(request: request, fractionComplete: fractionComplete)
                    case .inputComplete:
                        logger.log("Log: Data ingestion is completed. Beginning processing...")
                    case .invalidSample(let id, let reason):
                        logger.warning("Warning: Invalid Sample! id=\(id) reason=\"\(reason)\"")
                    case .skippedSample(let id):
                        logger.warning("Warning: Sample id=\(id) was skipped by processing.")
                    case .automaticDownsampling:
                        logger.warning("Warning: Automatic downsampling was applied!")
                    case .processingCancelled:
                        logger.warning("Warning: Processing was cancelled.")
                        isProcessing = false
                    @unknown default:
                        logger.error("Error: Unhandled message: \(output.localizedDescription)")
                    }
                }
            } catch {
                logger.error("Error: \(String(describing: error))")
            }
        }
    }

    private func handleRequestComplete(
        request: PhotogrammetrySession.Request, result: PhotogrammetrySession.Result
    ) {
        logger.log("Log: Request complete: \(String(describing: request)) with result...")
        switch result {
        case .modelFile(let url):
            logger.log("Log: modelFile available at url=\(url)")
        default:
            logger.warning("Warning: Unexpected result, \(String(describing: result))")
        }
    }

    private func handleRequestProgress(
        request: PhotogrammetrySession.Request, fractionComplete: Double
    ) {
        progress = fractionComplete
    }
}
