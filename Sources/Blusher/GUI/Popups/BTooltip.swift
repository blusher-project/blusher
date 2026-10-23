open class BTooltip: BPopup {
    private var _target: BView!

    public var target: BView {
        _target
    }

    public init(for target: BView, parent: BDesktopSurface) {
        _target = target

        super.init(at: Point(x: 0.0, y: 0.0), parent)
    }
}
