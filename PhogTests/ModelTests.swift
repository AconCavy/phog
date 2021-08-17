import RealityKit
import XCTest

@testable import Phog

class ModelTests: XCTestCase {

    func testMakeSessionNoThrows() {
        let sut = createDefaultModel()

        XCTAssertNoThrow(try sut.makeSession())
    }

    func testMakeSessionThrowsInvalidInput() {
        var sut = createDefaultModel()
        sut.input = nil

        XCTAssertThrowsError(try sut.makeSession()) { error in
            XCTAssertEqual(error as! Model.OptionError, .invalidInput)
        }
    }

    func testMakeRequestNoThrows() {
        let sut = createDefaultModel()

        XCTAssertNoThrow(try sut.makeRequest())
    }

    func testMakeRequestThrowsInvalidOutput() {
        var sut = createDefaultModel()
        sut.output = nil

        XCTAssertThrowsError(try sut.makeRequest()) { error in
            XCTAssertEqual(error as! Model.OptionError, .invalidOutput)
        }
    }

    func testMakeRequestThrowsInvalidFilename() {
        var sut = createDefaultModel()
        sut.filename = nil

        XCTAssertThrowsError(try sut.makeRequest()) { error in
            XCTAssertEqual(error as! Model.OptionError, .invalidFilename)
        }
    }

    func createDefaultModel() -> Model {
        var model = Model()
        model.input = URL(fileURLWithPath: "./sample/", isDirectory: true)
        model.output = URL(fileURLWithPath: "./sample/", isDirectory: true)
        model.filename = "sample.usdz"

        return model
    }

}