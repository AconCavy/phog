import Foundation
import RealityKit

struct PhotogrammetryModel {
    let input: URL
    let output: URL
    let filename: String
    let fileExtension: FileExtension
    let sampleOrdering: SampleOrdering
    let featureSensitivity: FeatureSensitivity
    let detail: Detail

    init(
        input: URL, output: URL, filename: String,
        fileExtension: FileExtension = .usdz,
        sampleOrdering: SampleOrdering = .unordered,
        featureSensitivity: FeatureSensitivity = .normal,
        detail: Detail = .medium
    ) throws {

        self.input = input
        self.output = output
        self.filename = filename
        self.fileExtension = fileExtension
        self.sampleOrdering = sampleOrdering
        self.featureSensitivity = featureSensitivity
        self.detail = detail

        if !existsDirectory(path: self.input.path) {
            throw OptionError.invalidInput
        }

        if !existsDirectory(path: self.output.path) {
            throw OptionError.invalidOutput
        }

        let regex = try! NSRegularExpression(
            pattern: "[\\\\/:\0]", options: NSRegularExpression.Options())
        let matches = regex.matches(
            in: self.filename, options: NSRegularExpression.MatchingOptions(),
            range: NSMakeRange(0, self.filename.count))
        if self.filename.isEmpty || matches.count > 0 {
            throw OptionError.invalidFilename
        }
    }

    private func existsDirectory(path: String) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
            && isDirectory.boolValue
    }
}

extension PhotogrammetryModel {
    func makeConfiguration() -> PhotogrammetrySession.Configuration {
        return PhotogrammetryModel.makeConfiguration(model: self)
    }

    func makeSession() throws -> PhotogrammetrySession {
        return try PhotogrammetryModel.makeSession(model: self)
    }

    func makeRequest() -> PhotogrammetrySession.Request {
        return PhotogrammetryModel.makeRequest(model: self)
    }

    static func makeConfiguration(model: PhotogrammetryModel) -> PhotogrammetrySession.Configuration
    {
        var configuration = PhotogrammetrySession.Configuration()
        configuration.sampleOrdering = PhotogrammetrySession.Configuration.SampleOrdering(
            model.sampleOrdering)
        configuration.featureSensitivity = PhotogrammetrySession.Configuration.FeatureSensitivity(
            model.featureSensitivity)

        return configuration
    }

    static func makeSession(model: PhotogrammetryModel) throws -> PhotogrammetrySession {
        return try PhotogrammetrySession(
            input: model.input, configuration: makeConfiguration(model: model))
    }

    static func makeRequest(model: PhotogrammetryModel) -> PhotogrammetrySession.Request {
        let url = model.output
            .appendingPathComponent(model.filename)
            .appendingPathExtension(model.fileExtension.rawValue)
        let detail = PhotogrammetrySession.Request.Detail(model.detail)
        return PhotogrammetrySession.Request.modelFile(url: url, detail: detail)
    }
}
