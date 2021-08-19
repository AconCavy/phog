enum FileExtension: String, CaseIterable, Identifiable {
    case usdz
    case usda
    case obj

    var id: String { self.rawValue }
}
