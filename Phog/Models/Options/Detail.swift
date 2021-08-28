import RealityKit

enum Detail: String, CaseIterable, Identifiable {
    case preview
    case reduced
    case medium
    case full
    case raw

    var id: String { self.rawValue }
}

extension PhotogrammetrySession.Request.Detail {
    init(_ detail: Detail) {
        switch detail {
        case .preview:
            self = .preview
        case .reduced:
            self = .reduced
        case .medium:
            self = .medium
        case .full:
            self = .full
        case .raw:
            self = .raw
        }
    }
}
