protocol Loggable {
    mutating func log(_ message: String)
    mutating func warning(_ message: String)
    mutating func error(_ message: String)
}
