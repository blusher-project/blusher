public extension Declarative {

struct CenterLayout<Content: View>: Declarative.Layout, View {
    public var content: Content

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

    public func constraintFunction(_ root: BView) -> Void {
        print("constraintFunction!")
        if root.layoutConstraint == nil { return }

        for child in root.layoutConstraint!.childNodes {
            child.geometry = Rect(
                x: (root.size.width - child.size.width) / 2.0,
                y: (root.size.height - child.size.height) / 2.0,
                width: child.size.width,
                height: child.size.height
            )
        }
    }
}

}
