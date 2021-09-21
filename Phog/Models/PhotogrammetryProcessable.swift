protocol PhotogrammetryProcessable: AnyObject {
    var logger: Loggable? { get set }
    var handler: OutputHandleable? { get set }
    func process(model: PhotogrammetryModel) async
}
