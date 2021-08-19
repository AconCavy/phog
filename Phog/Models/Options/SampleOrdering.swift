import RealityKit

enum SampleOrdering: String, CaseIterable, Identifiable {
    case none
    case unordered
    case sequential

    var id: String { self.rawValue }
}

extension SampleOrdering {
    func map() -> PhotogrammetrySession.Configuration.SampleOrdering? {
        return SampleOrdering.map(self)
    }

    static func map(_ sampleOrdering: SampleOrdering) -> PhotogrammetrySession.Configuration
        .SampleOrdering?
    {
        switch sampleOrdering {
        case .none:
            return nil
        case .unordered:
            return .unordered
        case .sequential:
            return .sequential
        }
    }
}
