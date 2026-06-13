public struct FillLayout: Layout {
    private var _view: BView? = nil

    public init() {
    }

    public mutating func attach(to view: BView) {
        _view = view
    }

    public mutating func detach() {
        _view = nil
    }

    public func constraintFunction() -> Void {
        if _view == nil {
            return
        }
        for child in _view!.children {
            child.geometry = Rect(
                x: 0.0,
                y: 0.0,
                width: _view!.size.width,
                height: _view!.size.height
            )
        }
    }
}
