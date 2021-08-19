import Foundation
import RealityKit

struct PhotogrammetryModel {
    var input: String?
    var output: String?
    var filename: String?
    var fileExtension: String?
    var sampleOrdering: PhotogrammetrySession.Configuration.SampleOrdering?
    var featureSensitivity: PhotogrammetrySession.Configuration.FeatureSensitivity?
    var detail: PhotogrammetrySession.Request.Detail?
    var geometry: PhotogrammetrySession.Request.Geometry?
}

extension PhotogrammetryModel {
    func makeSession() throws -> PhotogrammetrySession? {
        guard let input = input else {
            throw OptionError.invalidInput
        }

        let url = URL(fileURLWithPath: input, isDirectory: true)

        if !existsDirectory(path: url.path) {
            throw OptionError.invalidInput
        }

        let configuration = PhotogrammetryModel.makeConfiguration(
            sampleOrdering: self.sampleOrdering,
            featureSensitivity: self.featureSensitivity)

        do {
            return try PhotogrammetrySession(input: url, configuration: configuration)
        } catch {
            return nil
        }
    }

    func makeRequest() throws -> PhotogrammetrySession.Request {
        guard let output = output else {
            throw OptionError.invalidOutput
        }

        var url = URL(fileURLWithPath: output, isDirectory: true)

        if !existsDirectory(path: url.path) {
            throw OptionError.invalidOutput
        }

        guard let filename = filename else {
            throw OptionError.invalidFilename
        }

        guard let fileExtension = fileExtension else {
            throw OptionError.invalidFileExtension
        }

        url = url.appendingPathComponent(filename).appendingPathExtension(fileExtension)

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

        switch (detail, geometry) {
        case let (.some(d), .some(g)):
            return PhotogrammetrySession.Request.modelFile(url: output, detail: d, geometry: g)
        case let (.some(d), nil):
            return PhotogrammetrySession.Request.modelFile(url: output, detail: d)
        default:
            return PhotogrammetrySession.Request.modelFile(url: output)
        }
    }

    private func existsDirectory(path: String) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
            && isDirectory.boolValue
    }
}
