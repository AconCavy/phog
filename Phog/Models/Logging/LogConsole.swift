import os

struct LogConsole: Loggable {
    var output: [(LogType, String)] = []
    private let logger = Logger(subsystem: "acon.phog", category: "Phog")

    mutating func log(_ message: String) {
        let formatted = "Log: \(message)"
        self.output.append((.log, formatted))
        self.logger.log("\(formatted)")
    }

    mutating func warning(_ message: String) {
        let formatted = "Warning: \(message)"
        self.output.append((.warning, formatted))
        self.logger.log("\(formatted)")
    }

    mutating func error(_ message: String) {
        let formatted = "Error: \(message)"
        self.output.append((.error, formatted))
        self.logger.log("\(formatted)")
    }

    mutating func clear() {
        self.output.removeAll()
    }
}
