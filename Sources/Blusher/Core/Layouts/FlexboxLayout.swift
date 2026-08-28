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

    public enum JustifyContent {
        case normal
        case center
        case spaceBetween
    }

    public enum AlignItems {
        case normal
        case center
    }

    private var _view: BView? = nil
    private var _spacing: Double = 0.0
    private var _flexDirection: FlexDirection = .column
    private var _justifyContent: JustifyContent = .normal
    private var _alignItems: AlignItems = .normal

    public var spacing: Double {
        get { _spacing }
        set { _spacing = newValue }
    }

    public var flexDirection: FlexDirection {
        get { _flexDirection }
        set { _flexDirection = newValue }
    }

    public var justifyContent: JustifyContent {
        get { _justifyContent }
        set { _justifyContent = newValue }
    }

    public var alignItems: AlignItems {
        get { _alignItems }
        set { _alignItems = newValue }
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

        // Justify content.
        switch self.justifyContent {
        case .normal:
            break
        case .center:
            YGNodeStyleSetJustifyContent(ygRoot, YGJustifyCenter)
        case .spaceBetween:
            YGNodeStyleSetJustifyContent(ygRoot, YGJustifySpaceBetween)
        }

        // Align items.
        switch self.alignItems {
        case .normal:
            break
        case .center:
            YGNodeStyleSetAlignItems(ygRoot, YGAlignCenter)
        }

        var nodes: [YGNodeRef] = []
        for i in 0..<view.children.count {
            let child = view.children[i]

            let node = YGNodeNew()
            YGNodeStyleSetWidth(node, Float(child.geometry.width))
            YGNodeStyleSetHeight(node, Float(child.geometry.height))
            YGNodeInsertChild(ygRoot, node, i)
            nodes.append(node!)
        }
        YGNodeCalculateLayout(ygRoot,
            Float(view.geometry.width), Float(view.geometry.height),
            YGDirectionLTR)

        for i in 0..<nodes.count {
            let child = view.children[i]
            let node = nodes[i]

            let x = YGNodeLayoutGetLeft(node)
            let y = YGNodeLayoutGetTop(node)
            let width = YGNodeLayoutGetWidth(node)
            let height = YGNodeLayoutGetHeight(node)

            child.geometry = Rect(
                x: Double(x),
                y: Double(y),
                width: Double(width),
                height: Double(height)
            )
        }

        YGNodeFreeRecursive(ygRoot)
    }
}
