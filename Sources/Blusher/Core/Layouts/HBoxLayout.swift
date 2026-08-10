public struct HBoxLayout: Layout {
    private var _view: BView? = nil
    private var _spacing: Double = 0.0

    public var spacing: Double {
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

        var totalWidth: Double = 0.0
        for child in view.children {
            child.position = Point(x: totalWidth, y: child.position.y)
            totalWidth += child.size.width + _spacing
        }
    }
}
