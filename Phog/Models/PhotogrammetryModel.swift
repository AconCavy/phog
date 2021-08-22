import Foundation
import RealityKit

struct PhotogrammetryModel {
    let input: URL
    let output: URL
    let filename: String
    let fileExtension: FileExtension
    var sampleOrdering: PhotogrammetrySession.Configuration.SampleOrdering?
    var featureSensitivity: PhotogrammetrySession.Configuration.FeatureSensitivity?
    var detail: PhotogrammetrySession.Request.Detail?
    var geometry: PhotogrammetrySession.Request.Geometry?

    init(
        input: URL, output: URL, filename: String, fileExtension: FileExtension,
        sampleOrdering: PhotogrammetrySession.Configuration.SampleOrdering? = nil,
        featureSensitivity: PhotogrammetrySession.Configuration.FeatureSensitivity? = nil,
        detail: PhotogrammetrySession.Request.Detail? = nil,
        geometry: PhotogrammetrySession.Request.Geometry? = nil
    ) throws {

        self.input = input
        self.output = output
        self.filename = filename
        self.fileExtension = fileExtension
        self.sampleOrdering = sampleOrdering
        self.featureSensitivity = featureSensitivity
        self.detail = detail
        self.geometry = geometry

        if !existsDirectory(path: self.input.path) {
            throw OptionError.invalidInput
        }

        if !existsDirectory(path: self.output.path) {
            throw OptionError.invalidOutput
        }

        if self.filename.isEmpty {
            throw OptionError.invalidFilename
        }
    }
}

extension PhotogrammetryModel {
    func makeSession() throws -> PhotogrammetrySession {
        let configuration = PhotogrammetryModel.makeConfiguration(
            sampleOrdering: self.sampleOrdering,
            featureSensitivity: self.featureSensitivity)

        return try PhotogrammetrySession(input: self.input, configuration: configuration)
    }

    func makeRequest() -> PhotogrammetrySession.Request {
        let url = output.appendingPathComponent(filename).appendingPathExtension(
            fileExtension.rawValue)

        return PhotogrammetryModel.makeRequest(
            output: url, detail: self.detail, geometry: self.geometry)
    }

    private static func makeConfiguration(
        sampleOrdering: PhotogrammetrySession.Configuration.SampleOrdering?,
        featureSensitivity: PhotogrammetrySession.Configuration.FeatureSensitivity?
    ) -> PhotogrammetrySession.Configuration {
        var configuration = PhotogrammetrySession.Configuration()
        sampleOrdering.map { configuration.sampleOrdering = $0 }
        featureSensitivity.map { configuration.featureSensitivity = $0 }

        return configuration
    }

    private static func makeRequest(
        output: URL, detail: PhotogrammetrySession.Request.Detail?,
        geometry: PhotogrammetrySession.Request.Geometry?
    ) -> PhotogrammetrySession.Request {

        if let detail = detail {
            return PhotogrammetrySession.Request.modelFile(
                url: output, detail: detail, geometry: geometry)
        }

        return PhotogrammetrySession.Request.modelFile(url: output, geometry: geometry)
    }

    private func existsDirectory(path: String) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
            && isDirectory.boolValue
    }
}
