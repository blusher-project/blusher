public struct VBoxLayout: Layout {
    private var _view: BView? = nil
    private var _spacing: Float = 0.0

    public var spacing: Float {
        get { _spacing }
        set { _spacing = newValue }
    }

    public mutating func attach(to view: BView) {
        _view = view
    }

    public mutating func detach() {
        _view = nil
    }

    public func constraintFunction() -> Void {
        guard let view = _view else { return }

        var totalHeight: Float = 0.0
        for child in view.children {
            child.position = Point(x: child.position.x, y: totalHeight)
            totalHeight += child.size.height + _spacing
        }
    }
}
