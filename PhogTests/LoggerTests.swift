import XCTest

@testable import Phog

class LoggerTests: XCTestCase {

    func testLog() {
        var sut = Logger()

        let message = "Log: Foo"
        sut.log(message)

        let expected = (Logger.LogType.log, message)
        XCTAssertEqual(sut.output.count, 1)

        let actual = sut.output.first
        XCTAssertEqual(actual?.0, expected.0)
        XCTAssertEqual(actual?.1, expected.1)
    }

    func testWarning() {
        var sut = Logger()

        let message = "Warning: Foo"
        sut.warning(message)

        let expected = (Logger.LogType.warning, message)
        XCTAssertEqual(sut.output.count, 1)

        let actual = sut.output.first
        XCTAssertEqual(actual?.0, expected.0)
        XCTAssertEqual(actual?.1, expected.1)
    }

    func testError() {
        var sut = Logger()

        let message = "Error: Foo"
        sut.error(message)

        let expected = (Logger.LogType.error, message)
        XCTAssertEqual(sut.output.count, 1)

        let actual = sut.output.first
        XCTAssertEqual(actual?.0, expected.0)
        XCTAssertEqual(actual?.1, expected.1)
    }

    func testClear() {
        var sut = Logger()

        let messages = ["Log", "Warning", "Error"]
        sut.log(messages[0])
        sut.warning(messages[1])
        sut.error(messages[2])

        XCTAssertEqual(sut.output.count, 3)

        sut.clear()
        XCTAssertEqual(sut.output.count, 0)
    }

}
