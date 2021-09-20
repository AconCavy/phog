import RealityKit

class PhotogrammetryProcessor: PhotogrammetryProcessable {
    let logger: Loggable?
    let handler: OutputHandleable?

    init(logger: Loggable? = nil, handler: OutputHandleable? = nil) {
        self.logger = logger
        self.handler = handler
    }

    func process(model: PhotogrammetryModel) async {
        let session: PhotogrammetrySession

        do {
            session = try model.makeSession()
        } catch {
            await MainActor.run {
                logger?.error(
                    "Failed to make session. Please check the minumum execution environment")
            }
            return
        }

        let handleSessionOutputsTask = Task { await handleSessionOutputs(session) }
        let request = model.makeRequest()
        await MainActor.run {
            logger?.log("Start to processing...")
            logger?.log("Using request \(String(describing: request))")
        }

        withExtendedLifetime((session, handleSessionOutputsTask)) {
            do {
                try session.process(requests: [request])
            } catch {
                Task {
                    await MainActor.run {
                        logger?.error(String(describing: error))
                    }
                }
            }
        }

        while session.isProcessing {
            try? await Task.sleep(nanoseconds: 100_000_000)

            if Task.isCancelled {
                session.cancel()
                break
            }
        }
    }

    private func handleSessionOutputs(_ session: PhotogrammetrySession) async {
        do {
            for try await output in session.outputs {
                await MainActor.run {
                    switch output {
                    case .inputComplete:
                        handler?.handleInputComplete()
                    case .requestError(let request, let error):
                        handler?.handleRequestError(request: request, error: error)
                    case .requestComplete(let request, let result):
                        handler?.handleRequestComplete(request: request, result: result)
                    case .requestProgress(let request, let fractionComplete):
                        handler?.handleRequestProgress(
                            request: request, fractionComplete: fractionComplete)
                    case .processingComplete:
                        handler?.handleProcessingComplete()
                    case .processingCancelled:
                        handler?.handleProcessingCancelled()
                    case .invalidSample(let id, let reason):
                        handler?.handleInvalidSample(id: id, reason: reason)
                    case .skippedSample(let id):
                        handler?.handleSkippedSample(id: id)
                    case .automaticDownsampling:
                        handler?.handleAutomaticDownsampling()
                    @unknown default:
                        logger?.error("Unhandled message: \(output.localizedDescription)")
                    }
                }
            }
        } catch {
            await MainActor.run {
                logger?.error(String(describing: error))
            }
        }
    }
}
