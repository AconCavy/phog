import RealityKit

@MainActor
protocol OutputHandleable {
    func handleInputComplete()
    func handleRequestError(request: PhotogrammetrySession.Request, error: Error)
    func handleRequestComplete(
        request: PhotogrammetrySession.Request, result: PhotogrammetrySession.Result)
    func handleRequestProgress(request: PhotogrammetrySession.Request, fractionComplete: Double)
    func handleProcessingComplete()
    func handleProcessingCancelled()
    func handleInvalidSample(id: Int, reason: String)
    func handleSkippedSample(id: Int)
    func handleAutomaticDownsampling()
}
