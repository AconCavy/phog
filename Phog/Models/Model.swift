import Foundation
import os
import RealityKit

struct Model {
    public var input: URL?
    public var output: URL?
    public var filename: String?
    
    public var sampleOrdering: PhotogrammetrySession.Configuration.SampleOrdering?
    public var featureSensitivity: PhotogrammetrySession.Configuration.FeatureSensitivity?
    public var detail: PhotogrammetrySession.Request.Detail?
    public var geometry: PhotogrammetrySession.Request.Geometry?
    
    public func makeSession() throws -> PhotogrammetrySession?
    {
        guard let input = input else {
            throw OptionError.invalidInput
        }
        
        let configuration = Model.makeConfiguration(sampleOrdering: self.sampleOrdering,
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
        
        return Model.makeRequest(output: output.appendingPathComponent(filename), detail: self.detail, geometry: self.geometry)
    }
    
    public enum OptionError: Error {
        case invalidInput
        case invalidOutput
        case invalidFilename
//        case invalidSampleOrdering
//        case invalidFeatureSensitivity
//        case invalidDetail
//        case invalidGeometry
    }
    
    private static func makeConfiguration(sampleOrdering: PhotogrammetrySession.Configuration.SampleOrdering?, featureSensitivity: PhotogrammetrySession.Configuration.FeatureSensitivity?) -> PhotogrammetrySession.Configuration {
        var configuration = PhotogrammetrySession.Configuration()
        sampleOrdering.map{ configuration.sampleOrdering = $0 }
        featureSensitivity.map{ configuration.featureSensitivity = $0 }
        
        return configuration
    }
    
    private static func makeRequest(output: URL, detail: PhotogrammetrySession.Request.Detail?, geometry: PhotogrammetrySession.Request.Geometry?) -> PhotogrammetrySession.Request {
        
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
