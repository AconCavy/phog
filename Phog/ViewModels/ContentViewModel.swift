import Foundation
import RealityKit
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject, OutputHandleable {
    static let defaultFilename = "modelFile"

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

    private let logger: Loggable
    private let processor: PhotogrammetryProcessable
    private var task: Task<Void, Never>?

    init(logger: Loggable, processor: PhotogrammetryProcessable) {
        self.logger = logger
        self.processor = processor
        self.processor.logger = self.logger
        self.processor.handler = self
    }

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

        self.isProcessing = true
        task = Task {
            await processor.process(model: model)
            await MainActor.run {
                resetStatus()
            }
        }
    }

    func cancelGeneration() {
        guard !self.isCancelling, let task = self.task else {
            return
        }

        logger.log("Cancel to processing...")
        self.isCancelling = true
        task.cancel()
        resetStatus()
    }

    private func makeModel() throws -> PhotogrammetryModel {
        guard let input = self.input else {
            throw OptionError.invalidInput
        }

        guard let output = self.output else {
            throw OptionError.invalidOutput
        }

        let filename = self.filename.isEmpty ? ContentViewModel.defaultFilename : self.filename

        return try PhotogrammetryModel(
            input: input, output: output, filename: filename, fileExtension: fileExtension,
            sampleOrdering: sampleOrdering, featureSensitivity: featureSensitivity, detail: detail)
    }

    func handleInputComplete() {
        logger.log("Data ingestion is completed. Beginning processing...")
    }

    func handleRequestError(request: PhotogrammetrySession.Request, error: Error) {
        logger.error(
            "Request \(String(describing: request)) had an error: \(String(describing: error))")
    }

    func handleRequestComplete(
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

    func handleRequestProgress(request: PhotogrammetrySession.Request, fractionComplete: Double) {
        self.progress = fractionComplete
    }

    func handleProcessingComplete() {
        logger.log("Processing was completed.")
    }

    func handleProcessingCancelled() {
        logger.warning("Processing was cancelled.")
    }

    func handleInvalidSample(id: Int, reason: String) {
        logger.warning("Sample id=\(id) is invalid. \(String(describing: reason))")
    }

    func handleSkippedSample(id: Int) {
        logger.warning("Sample id=\(id) was skipped by processing.")
    }

    func handleAutomaticDownsampling() {
        logger.warning("Automatic downsampling was applied.")
    }

    private func resetStatus() {
        self.isProcessing = false
        self.isCancelling = false
        self.progress = 0
    }
}
