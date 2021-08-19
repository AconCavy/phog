import XCTest

@testable import Phog

class LogConsoleTests: XCTestCase {

    func testLog() {
        var sut = LogConsole()

        let message = "Foo"
        sut.log(message)

        let expected = (LogType.log, "Log: \(message)")
        XCTAssertEqual(sut.output.count, 1)

        let actual = sut.output.first
        XCTAssertEqual(actual?.0, expected.0)
        XCTAssertEqual(actual?.1, expected.1)
    }

    func testWarning() {
        var sut = LogConsole()

        let message = "Foo"
        sut.warning(message)

        let expected = (LogType.warning, "Warning: \(message)")
        XCTAssertEqual(sut.output.count, 1)

        let actual = sut.output.first
        XCTAssertEqual(actual?.0, expected.0)
        XCTAssertEqual(actual?.1, expected.1)
    }

    func testError() {
        var sut = LogConsole()

        let message = "Foo"
        sut.error(message)

        let expected = (LogType.error, "Error: \(message)")
        XCTAssertEqual(sut.output.count, 1)

        let actual = sut.output.first
        XCTAssertEqual(actual?.0, expected.0)
        XCTAssertEqual(actual?.1, expected.1)
    }

}
