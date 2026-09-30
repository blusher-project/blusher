public protocol Layout {
    // @ViewBuilder
    // var body: Body { get }

    // var selfContent: any View { get }

    // var childrenContent: any View { get }

    var insets: Insets { get set }

    func constraintFunction() -> Void

    mutating func attach(to view: BView)

    mutating func detach()
}

extension Layout {
    public var insets: Insets {
        get { Insets(all: 0.0) }
        set { }
    }
}

public struct LayoutConstraint {
    var rootNode: BView
    var childNodes: [BView]
    var constraintFunction: ((BView) -> Void)
}
