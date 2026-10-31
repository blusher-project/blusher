open class BTooltip: BPopup {
    class View: BView {
        private var _label: BLabel!

        public var text: String {
            get { _label.text }
            set { _label.text = newValue }
        }

        public override var preferredSize: Size? {
            if let labelSize = _label.preferredSize {
                return Size(
                    width: labelSize.width + 8.0,
                    height: labelSize.height + 4.0
                )
            }
            return nil
        }

        init(surface: BSurface) {
            super.init(surface: surface, geometry: Rect(x: 0.0, y: 0.0, width: 80.0, height: 30.0))

            self.color = .yellow

            var layout = FlexboxLayout()
            layout.alignItems = .center
            layout.justifyContent = .center
            self.layout = layout

            _label = BLabel("", parent: self)

            self.layingOut()
        }
    }

    private var _target: BView!

    private var _view: BTooltip.View!

    public var text: String = "" {
        didSet {
            _view.text = text
            self.updateSurfaceSize()
        }
    }

    public var target: BView {
        _target
    }

    public init(for target: BView, parent: BDesktopSurface) {
        _target = target

        super.init(at: Point(x: 0.0, y: 0.0), parent)

        _view = BTooltip.View(surface: self.surface)
    }

    private func updateSurfaceSize() {
        self.surface.rootViewColor = .red
        self.surface.size = SizeI(
            width: Int(_view.preferredSize?.width ?? 80.0),
            height: Int(_view.preferredSize?.height ?? 30.0)
        )
        _view.size = self.surface.size.toSize()
    }
}
