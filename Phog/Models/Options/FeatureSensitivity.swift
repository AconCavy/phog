import RealityKit

enum FeatureSensitivity: String, CaseIterable, Identifiable {
    case normal
    case high

    var id: String { self.rawValue }
}

extension PhotogrammetrySession.Configuration.FeatureSensitivity {
    init(_ featureSensitivity: FeatureSensitivity) {
        switch featureSensitivity {
        case .normal:
            self = .normal
        case .high:
            self = .high
        }
    }
}
