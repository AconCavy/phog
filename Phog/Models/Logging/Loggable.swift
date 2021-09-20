@MainActor
protocol Loggable {
    func log(_ message: String)
    func warning(_ message: String)
    func error(_ message: String)
}
