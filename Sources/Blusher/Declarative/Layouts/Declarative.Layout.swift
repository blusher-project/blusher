public enum Declarative {

public protocol Layout: Visible {
    associatedtype Body : View

    @ViewBuilder
    var body: Body { get }

    var selfContent: any View { get }

    var childrenContent: any View { get }

    func constraintFunction(_: BView) -> Void
}

public struct LayoutConstraint {
    var rootNode: BView
    var childNodes: [BView]
    var constraintFunction: ((BView) -> Void)
}

}
