import RealityKit

enum FeatureSensitivity: String, CaseIterable, Identifiable {
    case none
    case normal
    case high

    var id: String { self.rawValue }
}

extension FeatureSensitivity {
    func map() -> PhotogrammetrySession.Configuration.FeatureSensitivity? {
        return FeatureSensitivity.map(self)
    }

    static func map(_ featureSensitivity: FeatureSensitivity) -> PhotogrammetrySession.Configuration
        .FeatureSensitivity?
    {
        switch featureSensitivity {
        case .none:
            return nil
        case .normal:
            return .normal
        case .high:
            return .high
        }
    }
}
