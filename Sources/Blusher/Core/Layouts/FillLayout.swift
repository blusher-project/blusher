public struct FillLayout: Layout {
    private var _view: BView? = nil

    public var insets: Insets = Insets(all: 0.0)

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
                x: self.insets.start,
                y: self.insets.top,
                width: _view!.size.width - (self.insets.start + self.insets.end),
                height: _view!.size.height - (self.insets.top + self.insets.bottom)
            )
        }
    }
}
