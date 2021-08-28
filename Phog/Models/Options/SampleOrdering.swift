import RealityKit

enum SampleOrdering: String, CaseIterable, Identifiable {
    case unordered
    case sequential

    var id: String { self.rawValue }
}

extension PhotogrammetrySession.Configuration.SampleOrdering {
    init(_ sampleOrdering: SampleOrdering) {
        switch sampleOrdering {
        case .unordered:
            self = .unordered
        case .sequential:
            self = .sequential
        }
    }
}
