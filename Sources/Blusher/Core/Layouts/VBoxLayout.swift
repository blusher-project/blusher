public struct VBoxLayout: Layout {
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

        var totalHeight: Double = 0.0
        for child in view.children {
            child.position = Point(x: child.position.x, y: totalHeight)
            totalHeight += child.size.height + _spacing
        }
    }
}
