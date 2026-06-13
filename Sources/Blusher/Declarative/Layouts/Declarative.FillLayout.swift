public extension Declarative {

struct FillLayout<Content: View>: Declarative.Layout {
    private var _view: BView? = nil

    public var content: Content!

    public init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        EmptyView()
    }

    public var selfContent: any View {
        Rectangle()
    }

    public var childrenContent: any View {
        content
    }

    public init(_ view: BView) {
        //
    }

    public init() {
        //
    }

    public mutating func attach(to view: BView) {
        _view = view
    }

    public mutating func detach() {
        _view = nil
    }

    public func constraintFunction(_ view: BView) -> Void {
        /*
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
        */
    }
}

}
