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
        let paths: [String?] = [nil, getSampleDirectoryPath() + "/file"]

        for path in paths {
            sut.input = path
            XCTAssertThrowsError(try sut.makeSession()) { error in
                XCTAssertEqual(error as! OptionError, .invalidInput)
            }
        }
    }

    func testMakeRequestNoThrows() {
        let sut = createDefaultModel()

        XCTAssertNoThrow(try sut.makeRequest())
    }

    func testMakeRequestThrowsInvalidOutput() {
        var sut = createDefaultModel()
        let paths: [String?] = [nil, getSampleDirectoryPath() + "/file"]

        for path in paths {
            sut.output = path
            XCTAssertThrowsError(try sut.makeRequest()) { error in
                XCTAssertEqual(error as! OptionError, .invalidOutput)
            }
        }
    }

    func testMakeRequestThrowsInvalidFilename() {
        var sut = createDefaultModel()

        sut.filename = nil
        XCTAssertThrowsError(try sut.makeRequest()) { error in
            XCTAssertEqual(error as! OptionError, .invalidFilename)
        }
    }

    private func createDefaultModel() -> PhotogrammetryModel {
        let path = getSampleDirectoryPath()
        return PhotogrammetryModel(
            input: path, output: path, filename: "sample", fileExtension: "usdz")
    }

    private func getSampleDirectoryPath() -> String {
        return FileManager.default.temporaryDirectory.path
    }

}
