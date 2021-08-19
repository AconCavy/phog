import Foundation
import RealityKit

struct PhotogrammetryModel {
    var input: URL?
    var output: URL?
    var filename: String?
    var sampleOrdering: PhotogrammetrySession.Configuration.SampleOrdering?
    var featureSensitivity: PhotogrammetrySession.Configuration.FeatureSensitivity?
    var detail: PhotogrammetrySession.Request.Detail?
    var geometry: PhotogrammetrySession.Request.Geometry?
}

extension PhotogrammetryModel {
    public func makeSession() throws -> PhotogrammetrySession? {
        guard let input = input else {
            throw OptionError.invalidInput
        }

        let configuration = PhotogrammetryModel.makeConfiguration(
            sampleOrdering: self.sampleOrdering,
            featureSensitivity: self.featureSensitivity)

        do {
            return try PhotogrammetrySession(input: input, configuration: configuration)
        } catch {
            return nil
        }
    }

    public func makeRequest() throws -> PhotogrammetrySession.Request {
        guard let output = output else {
            throw OptionError.invalidOutput
        }

        guard let filename = filename else {
            throw OptionError.invalidFilename
        }

        return PhotogrammetryModel.makeRequest(
            output: output.appendingPathComponent(filename), detail: self.detail,
            geometry: self.geometry)
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
}
