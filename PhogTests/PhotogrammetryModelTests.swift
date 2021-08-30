import RealityKit
import XCTest

@testable import Phog

class PhotogrammetryModelTests: XCTestCase {
    var sampleDirectoryURL: URL = URL(fileURLWithPath: "")
    var sampleFileURL: URL = URL(fileURLWithPath: "")
    var sampleFilename: String = "file"

    override func setUp() {
        sampleDirectoryURL = FileManager.default.temporaryDirectory
        sampleFileURL = sampleDirectoryURL.appendingPathComponent(sampleFilename)
    }

    func testInitNoThrows() {
        let input = sampleDirectoryURL
        let output = sampleDirectoryURL
        let filename = sampleFilename
        XCTAssertNoThrow(try PhotogrammetryModel(input: input, output: output, filename: filename))
    }

    func testInitThrowsInvalidInput() {
        let input = sampleFileURL
        let output = sampleDirectoryURL
        let filename = sampleFilename
        XCTAssertThrowsError(
            try PhotogrammetryModel(input: input, output: output, filename: filename)
        ) { error in
            XCTAssertEqual(error as! OptionError, .invalidInput)
        }
    }

    func testInitThrowsInvalidOutput() {
        let input = sampleDirectoryURL
        let output = sampleFileURL
        let filename = sampleFilename
        XCTAssertThrowsError(
            try PhotogrammetryModel(input: input, output: output, filename: filename)
        ) { error in
            XCTAssertEqual(error as! OptionError, .invalidOutput)
        }
    }

    func testInitThrowsInvalidFilenameWithInvalidCharacters() {
        let cases = ["/", "\\", ":", "\0"]

        for c in cases {
            let input = sampleDirectoryURL
            let output = sampleDirectoryURL
            let filename = "foo\(c)bar"
            XCTAssertThrowsError(
                try PhotogrammetryModel(input: input, output: output, filename: filename)
            ) { error in
                XCTAssertEqual(error as! OptionError, .invalidFilename)
            }
        }
    }

    func testInitThrowsInvalidFilenameWithEmptyFilename() {
        let input = sampleDirectoryURL
        let output = sampleDirectoryURL
        let filename = ""
        XCTAssertThrowsError(
            try PhotogrammetryModel(input: input, output: output, filename: filename)
        ) { error in
            XCTAssertEqual(error as! OptionError, .invalidFilename)
        }
    }
}
