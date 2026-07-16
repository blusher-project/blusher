public struct HBoxLayout: Layout {
    private var _view: BView? = nil
    private var _spacing: Float = 0.0

    public var spacing: Float {
        get { _spacing }
        set { _spacing = newValue }
    }

    public init() {
    }

    public mutating func attach(to view: BView) {
        _view = view
    }

    public mutating func detach() {
        _view = nil
    }

    public func constraintFunction() -> Void {
        guard let view = _view else { return }

        var totalWidth: Float = 0.0
        for child in view.children {
            child.position = Point(x: totalWidth, y: child.position.y)
            totalWidth += child.size.width + _spacing
        }
    }
}
