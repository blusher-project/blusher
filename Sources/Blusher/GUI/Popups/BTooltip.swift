open class BTooltip: BPopup {
    class View: BView {
        init(surface: BSurface) {
            super.init(surface: surface, geometry: Rect(x: 0.0, y: 0.0, width: 80.0, height: 10.0))

            self.color = .yellow
        }
    }

    private var _target: BView!

    private var _view: View!

    public var text: String = ""

    public var target: BView {
        _target
    }

    public init(for target: BView, parent: BDesktopSurface) {
        _target = target

        super.init(at: Point(x: 0.0, y: 0.0), parent)

        _view = BTooltip.View(surface: self.surface)
    }
}
