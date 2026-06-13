public protocol Layout {
    // @ViewBuilder
    // var body: Body { get }

    // var selfContent: any View { get }

    // var childrenContent: any View { get }

    func constraintFunction() -> Void

    mutating func attach(to view: BView)

    mutating func detach()
}

public struct LayoutConstraint {
    var rootNode: BView
    var childNodes: [BView]
    var constraintFunction: ((BView) -> Void)
}
