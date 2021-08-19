import RealityKit

enum Detail: String, CaseIterable, Identifiable {
    case preview
    case reduced
    case medium
    case full
    case raw

    var id: String { self.rawValue }
}

extension Detail {
    func map() -> PhotogrammetrySession.Request.Detail {
        return Detail.map(self)
    }

    static func map(_ detail: Detail) -> PhotogrammetrySession.Request.Detail {
        switch detail {
        case .preview:
            return .preview
        case .reduced:
            return .reduced
        case .medium:
            return .medium
        case .full:
            return .full
        case .raw:
            return .raw
        }
    }
}
