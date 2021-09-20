import Foundation
import os

class LogConsole: ObservableObject, Loggable {
    @Published var output: [(LogType, String)] = []
    private let logger = Logger(subsystem: "dev.aconcavy.Phog", category: "Phog")

    func log(_ message: String) {
        let formatted = "Log: \(message)"
        self.output.append((.log, formatted))
        self.logger.log("\(formatted)")
    }

    func warning(_ message: String) {
        let formatted = "Warning: \(message)"
        self.output.append((.warning, formatted))
        self.logger.log("\(formatted)")
    }

    func error(_ message: String) {
        let formatted = "Error: \(message)"
        self.output.append((.error, formatted))
        self.logger.log("\(formatted)")
    }

    func clear() {
        self.output.removeAll()
    }
}
