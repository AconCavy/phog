import Foundation
import SwiftUI
import RealityKit

class ContentViewModel: ObservableObject {
    @Published var model: Model = Model()
    @Published var logger: Logger = Logger()
    @Published var progress: Double = 0
    
    let notSelected = "Not Selcted"
    let defaultFilename = "modelFile.usdz"
    
    var isProcessing = false
    
    public enum SampleOrdering: String, CaseIterable, Identifiable {
        case none
        case unordered
        case sequential
        
        public var id: String { self.rawValue }
    }
    
    public enum FeatureSensitivity: String, CaseIterable, Identifiable {
        case none
        case normal
        case hight
        
        public var id: String { self.rawValue }
    }
    
    public enum Detail: String, CaseIterable, Identifiable {
        case preview
        case reduced
        case medium
        case full
        case raw
        
        public var id: String { self.rawValue }
    }
    
    public var input: String {
        return model.input?.relativeString ?? notSelected
    }
    
    public var output: String {
        return model.output?.relativeString ?? notSelected
    }
    
    public func setInput(url: URL?) {
        model.input = url
    }
    
    public func setOutput(url: URL?) {
        model.output = url
    }
    
    public func setFilename(filename: String?) {
        if let tmp = filename {
            model.filename = tmp.isEmpty ? defaultFilename : tmp
        } else {
            model.filename = defaultFilename
        }
    }
    
    public func setSampleOrdering(sampleOrdering: SampleOrdering) {
        switch sampleOrdering {
        case .none:
            model.sampleOrdering = nil
        case .unordered:
            model.sampleOrdering = .unordered
        case .sequential:
            model.sampleOrdering = .sequential
        }
    }
    
    public func setFeatureSensitivity(featureSensitivity: FeatureSensitivity) {
        switch featureSensitivity {
        case .none:
            model.featureSensitivity = nil
        case .normal:
            model.featureSensitivity = .normal
        case .hight:
            model.featureSensitivity = .high
        }
    }
    
    public func setDetail(detail: Detail) {
        switch detail {
        case .preview:
            model.detail = .preview
        case .reduced:
            model.detail = .reduced
        case .medium:
            model.detail = .medium
        case .full:
            model.detail = .full
        case .raw:
            model.detail = .raw
        }
    }
    
    public func generatePhotogrammetry() {
        var maybeSession: PhotogrammetrySession? = nil
        var maybeRequest: PhotogrammetrySession.Request? = nil
        
        if model.filename == nil {
            model.filename = defaultFilename
        }
        
        do {
            maybeSession = try model.makeSession()
            maybeRequest = try model.makeRequest()
        } catch Model.OptionError.invalidInput {
            logger.error("Error: The input is invalid. Please check the input.")
            return
        } catch Model.OptionError.invalidOutput {
            logger.error("Error: The output is invalid. Please check the output.")
            return
        } catch Model.OptionError.invalidFilename {
            logger.error("Error: The filename is invalid. Please check the filename.")
            return
        } catch {
            logger.error("Error: Failed to make a session and request")
            return
        }
        
        guard let session = maybeSession else {
            logger.error("Error: Failed to make session. Please check the minumum execution environment")
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
                try session.process(requests: [ request ])
            } catch {
                logger.error("Error: \(String(describing: error))")
            }
        }
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
    
    private func handleRequestComplete(request: PhotogrammetrySession.Request, result: PhotogrammetrySession.Result) {
        logger.log("Log: Request complete: \(String(describing: request)) with result...")
        switch result {
        case .modelFile(let url):
            logger.log("Log: modelFile available at url=\(url)")
        default:
            logger.warning("Warning: Unexpected result, \(String(describing: result))")
        }
    }
    
    private func handleRequestProgress(request: PhotogrammetrySession.Request, fractionComplete: Double) {
        progress = fractionComplete
    }
}
