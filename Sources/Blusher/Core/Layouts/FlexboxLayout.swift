internal import CYoga

public struct FlexboxLayout: Layout {
    public enum FlexDirection {
        case column
        case row
    }

    public enum Direction {
        case ltr
        case rtl
    }

    private var _view: BView? = nil
    private var _spacing: Double = 0.0
    private var _flexDirection: FlexDirection = .column

    public var spacing: Double {
        get { _spacing }
        set { _spacing = newValue }
    }

    public var flexDirection: FlexDirection {
        get { _flexDirection }
        set { _flexDirection = newValue }
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

        let ygRoot = YGNodeNew()
        YGNodeStyleSetWidth(ygRoot, Float(view.geometry.width))
        YGNodeStyleSetHeight(ygRoot, Float(view.geometry.height))

        YGNodeStyleSetFlexDirection(ygRoot,
            (_flexDirection == .column) ? YGFlexDirectionColumn : YGFlexDirectionRow)

        var nodes: [YGNodeRef] = []
        for i in 0..<view.children.count {
            let child = view.children[i]

            let node = YGNodeNew()
            YGNodeStyleSetWidth(node, Float(child.geometry.width))
            YGNodeStyleSetHeight(node, Float(child.geometry.height))
            YGNodeInsertChild(ygRoot, node, i)
            nodes.append(node!)
        }
        YGNodeCalculateLayout(ygRoot, 0.0, 0.0, YGDirectionLTR)

        for i in 0..<nodes.count {
            let child = view.children[i]
            let node = nodes[i]

            let x = YGNodeLayoutGetLeft(node)
            let y = YGNodeLayoutGetTop(node)
            let width = YGNodeLayoutGetWidth(node)
            let height = YGNodeLayoutGetHeight(node)

            child.geometry = Rect(
                x: (_flexDirection == .row) ? child.geometry.x : Double(x),
                y: (_flexDirection == .column) ? child.geometry.y : Double(y),
                width: Double(width),
                height: Double(height)
            )
        }

        YGNodeFreeRecursive(ygRoot)
    }
}
