enum FileExtension: String, CaseIterable, Identifiable {
    case usdz

    var id: String { self.rawValue }
}
