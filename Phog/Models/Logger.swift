import Foundation

struct Logger {
    public var output: [(LogType, String)] = []

    public enum LogType {
        case log
        case warning
        case error
    }

    public mutating func log(_ message: String) {
        self.output.append((.log, message))
    }

    public mutating func warning(_ message: String) {
        self.output.append((.warning, message))
    }

    public mutating func error(_ message: String) {
        self.output.append((.error, message))
    }

    public mutating func clear() {
        self.output.removeAll()
    }
}
