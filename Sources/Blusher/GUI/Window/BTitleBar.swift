public class BTitleBar: BView {
    public class ButtonGroup: BView {
        private var _close: Button?
        private var _minimize: Button?
        private var _maximizeOrRstore: Button?

        public init(_ titleBar: BTitleBar) {
            super.init(parent: titleBar, geometry: Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))

            super.color = .transparent

            // Layout.
            var layout = FlexboxLayout()
            layout.flexDirection = .row
            layout.justifyContent = .spaceBetween
            layout.alignItems = .center
            self.layout = layout

            _close = Button(to: .close, of: titleBar, in: self)
            _minimize = Button(to: .minimize, of: titleBar, in: self)
            _maximizeOrRstore = Button(to: .maximizeOrRestore, of: titleBar, in: self)
        }
    }

    public class HeaderGroup: BView {
        //
    }

    public class Button: BView {
        enum Action {
            case close
            case minimize
            case maximizeOrRestore
        }

        private let _action: Action
        private let _titleBar: BTitleBar
        private let _image: ImageHandle
        private let _altImage: ImageHandle?
        private var _title: String = ""

        public var title: String {
            get { _title }
            set {
                _title = newValue
            }
        }

        init(to action: Action, of titleBar: BTitleBar, in group: ButtonGroup) {
            _action = action
            _titleBar = titleBar
            _image = switch action {
            case .close: ImageHandle(fromURL: "brc:///org.blusher.Blusher/close.png")
            case .minimize: ImageHandle(fromURL: "brc:///org.blusher.Blusher/minimize.png")
            case .maximizeOrRestore: ImageHandle(fromURL: "brc:///org.blusher.Blusher/maximize.png")
            }
            _altImage = nil
            super.init(parent: group, geometry: Rect(x: 10.0, y: 6.0, width: 24.0, height: 24.0))

            self.renderType = .image
            self.image = _image
            self.isAntialiased = true
        }

        public override func pointerPressEvent(_ event: PointerEvent) {
            event.propagation = false
        }

        public override func pointerClickEvent(_ event: PointerEvent) {
            if event.button == .left {
                switch _action {
                case .close: _titleBar._window.close()
                case .minimize: _titleBar._window.minimize()
                case .maximizeOrRestore:
                    _titleBar._window.maximize()
                }
            }
        }
    }

    public class Icon: BView {
        init(_ titleBar: BTitleBar) {
            let rect = Rect(x: 100.0, y: 0.0, width: 28.0, height: 28.0)
            super.init(parent: titleBar, geometry: rect)

            self.renderType = .image
            self.image = ImageHandle(fromURL: "brc:///org.blusher.Blusher/blusher-icon.png")
            self.isAntialiased = true
        }

        /*
        public override func paintEvent(_ event: Event) {
            var paint = Paint()
            paint.strokeWidth = 1.0
            paint.strokeColor = .red

            self.canvas?.drawLine(
                Point(x: 0.0, y: 10.0),
                Point(x: 30.0, y: 10.0),
                paint
            )

            super.paintEvent(event)
        }
        */
    }

    public class Caption: BView {
        init(_ titleBar: BTitleBar) {
            let rect = Rect(x: 140.0, y: 0.0, width: 100.0, height: BTitleBar.thickness)
            super.init(parent: titleBar, geometry: rect)

            self.renderType = .text
            self.textLayout = TextLayout()
            self.textLayout?.text = "Blusher Window"
        }
    }

    public static var thickness: Double {
        30.0
    }

    private var _window: BWindow
    private var _pressed: Bool = false

    private var _closeButton: Button!
    private var _minimizeButton: Button!
    private var _maximizeOrRestoreButton: Button!

    private var _buttonGroup: ButtonGroup!

    private var _icon: Icon!
    private var _caption: Caption!

    init(_ window: BWindow) {
        _window = window

        super.init(
            surface: window.surface,
            geometry: Rect(x: 0.0, y: 0.0, width: 10.0, height: 30.0)
        )

        // Title bar button group.
        _buttonGroup = ButtonGroup(self)
        _buttonGroup.geometry = Rect(x: 4.0, y: 0.0, width: 80.0, height: 30.0)

        // Title bar buttons.
        // _closeButton = Button(to: .close, of: self)
        // _minimizeButton = Button(to: .minimize, of: self)
        // _maximizeOrRestoreButton = Button(to: .maximizeOrRestore, of: self)

        // Title bar button geometries.
        // _closeButton.position = Point(x: 10.0, y: 3.0)
        // _minimizeButton.position = Point(x: 40.0, y: 3.0)
        // _maximizeOrRestoreButton.position = Point(x: 70.0, y: 3.0)

        _icon = Icon(self)
        _caption = Caption(self)

        self.color = Color(r256: 0xC1, g: 0xBB, b: 0xB8, a: 255)
        self.radius = Radius(topLeft: 8.0, topRight: 8.0, bottomRight: 0.0, bottomLeft: 0.0)
    }

    public override func pointerPressEvent(_ event: PointerEvent) {
        if event.button == .left {
            _pressed = true
        } else if event.button == .right {
            var pos = self.absolutePosition
            pos.x += event.position.x
            pos.y += event.position.y
            self._window.showWindowMenu(at: PointI(x: Int(pos.x), y: Int(pos.y)))
        }
    }

    public override func pointerMoveEvent(_ event: PointerEvent) {
        if _pressed == true {
            _window.move()
            _pressed = false
        }
    }
}
