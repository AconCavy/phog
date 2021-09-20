import RealityKit

class MockProcessor: PhotogrammetryProcessable {
    let logger: Loggable?
    let handler: OutputHandleable?

    var isProcessing: Bool

    init(logger: Loggable? = nil, handler: OutputHandleable? = nil) {
        self.logger = logger
        self.handler = handler
        isProcessing = false
    }

    func process(model: PhotogrammetryModel) async {
        let request = model.makeRequest()
        await MainActor.run {
            logger?.log("Start to processing...")
            logger?.log("Using request \(String(describing: request))")
            handler?.handleInputComplete()
        }

        let seconds: UInt64 = 1_000_000_000
        isProcessing = true
        let task = Task {
            try? await Task.sleep(nanoseconds: 10 * seconds)
            isProcessing = false
        }

        var time: UInt64 = 0
        let delta: UInt64 = 1
        while isProcessing {

            try? await Task.sleep(nanoseconds: delta * seconds)
            time += delta

            await MainActor.run { [time] in
                handler?.handleRequestProgress(
                    request: request, fractionComplete: min(Double(time) / 10, 1))
            }

            if Task.isCancelled {
                task.cancel()
                break
            }
        }

        await MainActor.run {
            if Task.isCancelled {
                handler?.handleProcessingCancelled()
            } else {
                handler?.handleProcessingComplete()
            }
        }
    }
}
