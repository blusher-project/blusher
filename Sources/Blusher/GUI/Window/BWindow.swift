open class BWindow: BToplevel {
    public var surfaceSize: SizeI {
        get { super.surface.size }
        set { super.surface.size = newValue }
    }

    public var size: SizeI {
        get { super.surface.size }
        set {
            super.surface.size = newValue

            _shadow.size = Size(
                width: Double(surfaceSize.width),
                height: Double(surfaceSize.height)
            )
            self.updateGeometries()
        }
    }

    public var frameSize: SizeI {
        get {
            SizeI(
                width: Int(_borderGeometry.width),
                height: Int(_borderGeometry.height)
            )
        }
    }

    private var _shadow: BWindowShadow!
    private var _resize: BWindowResize!
    private var _border: BWindowBorder!
    private var _titleBar: BTitleBar!
    private var _menuBar: BMenuBar? = nil
    private var _body: BView!
    private var _noDecoration: Bool = false

    public var body: BView {
        return _body
    }

    private var _wmGeometry: RectI {
        if self.noDecoration {
            return RectI(x: 0, y: 0, width: surfaceSize.width, height: surfaceSize.height)
        }

        let x = Int(_borderGeometry.x)
        let y = Int(_borderGeometry.y)
        let width = Int(_borderGeometry.width - BWindowBorder.thickness * 2)
        let height = Int(_borderGeometry.height - BWindowBorder.thickness * 2)

        return RectI(x: x, y: y, width: width, height: height)
    }

    private var _inputGeometry: RectI {
        if self.noDecoration {
            return RectI(x: 0, y: 0, width: surfaceSize.width, height: surfaceSize.height)
        }

        let x = Int(_resizeGeometry.x)
        let y = Int(_resizeGeometry.y)
        let width = Int(_resizeGeometry.width)
        let height = Int(_resizeGeometry.height)

        return RectI(x: x, y: y, width: width, height: height)
    }

    private var _resizeGeometry: Rect {
        let shadowThickness = !noDecoration ? BWindowShadow.thickness : 0.0
        let resizeThickness = !noDecoration ? BWindowResize.thickness : 0.0

        return Rect(
            x: shadowThickness - resizeThickness,
            y: shadowThickness - resizeThickness,
            width: Double(surfaceSize.width) - (shadowThickness * 2) + (resizeThickness * 2),
            height: Double(surfaceSize.height) - (shadowThickness * 2) + (resizeThickness * 2)
        )
    }

    private var _borderGeometry: Rect {
        return Rect(
            x: _resizeGeometry.x + BWindowResize.thickness - BWindowBorder.thickness,
            y: _resizeGeometry.y + BWindowResize.thickness - BWindowBorder.thickness,
            width: _resizeGeometry.width
                - (BWindowResize.thickness * 2) + (BWindowBorder.thickness * 2),
            height: _resizeGeometry.height
                - (BWindowResize.thickness * 2) + (BWindowBorder.thickness * 2)
        )
    }

    private var _titleBarGeometry: Rect {
        let shadowThickness = !self.noDecoration ? BWindowShadow.thickness : 0.0

        return Rect(
            x: shadowThickness,
            y: shadowThickness,
            width: _bodyGeometry.size.width,
            height: BTitleBar.thickness
        )
    }

    private var _menuBarGeometry: Rect {
        Rect(
            x: _titleBarGeometry.x,
            y: _titleBarGeometry.y + BTitleBar.thickness,
            width: _bodyGeometry.size.width,
            height: 24.0
        )
    }

    private var _bodyGeometry: Rect {
        let shadowThickness = !self.noDecoration ? BWindowShadow.thickness : 0.0

        var rect = Rect(
            x: shadowThickness,
            y: shadowThickness + BTitleBar.thickness,
            width: Double(surfaceSize.width) - (shadowThickness * 2),
            height: Double(surfaceSize.height) - (shadowThickness * 2) - BTitleBar.thickness
        )

        if let _ = _menuBar {
            rect.position.y += 24.0
            rect.size.height -= 24.0
        }

        return rect
    }

    private var noDecoration: Bool {
        get { _noDecoration }
        set {
            _noDecoration = newValue
            if _noDecoration == true {
                _shadow.isVisible = false
            } else {
                _shadow.isVisible = true
            }
        }
    }

    public init(_ parent: BWindow? = nil) {
        super.init(parent: parent)

        // Set window shadow.
        _shadow = BWindowShadow(self)
        _shadow.geometry = Rect(
            x: 0.0,
            y: 0.0,
            width: Double(self.surfaceSize.width),
            height: Double(self.surfaceSize.height)
        )

        // Set window resize area.
        _resize = BWindowResize(self)
        _resize.geometry = _resizeGeometry
        _resize.updateEdges()

        // Set window border.
        _border = BWindowBorder(self)
        _border.geometry = _borderGeometry

        // Set window title bar.
        _titleBar = BTitleBar(self)
        _titleBar.geometry = _titleBarGeometry

        // Window's body.
        _body = BView(surface: super.surface, geometry: _bodyGeometry)
    }

    internal func setMenuBar(_ menuBar: BMenuBar) {
        _menuBar = menuBar
        self.updateGeometries()
    }

    private func calculateShadowSize(_ size: Size) -> Size {
        return Size(
            width: size.width + WindowShadow.thickness * 2,
            height: size.height + WindowShadow.thickness * 2
        )
    }

    private func updateGeometries() {
        super.wmGeometry = _wmGeometry
        super.surface.inputGeometry = _inputGeometry

        _resize.geometry = _resizeGeometry
        _resize.updateEdges()
        _border.geometry = _borderGeometry
        _titleBar.geometry = _titleBarGeometry
        _menuBar?.geometry = _menuBarGeometry
        _body.geometry = _bodyGeometry
    }

    public override func show() {
        super.show()

        super.wmGeometry = _wmGeometry
        super.surface.inputGeometry = _inputGeometry
        super.minimumSize = SizeI(width: 100, height: 100)
    }

    public override func resizeRequestEvent(_ event: ResizeEvent) {
        let shadowSize = Size(
            width: event.size.width + BWindowShadow.thickness * 2,
            height: event.size.height + BWindowShadow.thickness * 2
        )
        self.surfaceSize = SizeI(width: Int(shadowSize.width), height: Int(shadowSize.height))
        _shadow.size = shadowSize
        self.updateGeometries()

        super.wmGeometry = _wmGeometry
        super.surface.inputGeometry = _inputGeometry
    }

    public override func stateChangeEvent(_ event: StateChangeEvent) {
        let state = event.state
        let on = event.isOn
        let size = event.size

        if state == .maximized && on == true {
            self.noDecoration = true
            self.surfaceSize = size
            updateGeometries()
        } else if state == .maximized && on == false {
            self.noDecoration = false
            _shadow.size = calculateShadowSize(Size(
                width: Double(size.width),
                height: Double(size.height)
            ))
            self.surfaceSize = SizeI(
                width: Int(_shadow.size.width),
                height: Int(_shadow.size.height)
            )
            updateGeometries()
        }
    }
}

public class BTitleBar: BView {
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

        init(to action: Action, of titleBar: BTitleBar) {
            _action = action
            _titleBar = titleBar
            _image = switch action {
            case .close: ImageHandle(fromURL: "brc:///org.blusher.Blusher/close.png")
            case .minimize: ImageHandle(fromURL: "brc:///org.blusher.Blusher/minimize.png")
            case .maximizeOrRestore: ImageHandle(fromURL: "brc:///org.blusher.Blusher/maximize.png")
            }
            _altImage = nil
            super.init(parent: titleBar, geometry: Rect(x: 10.0, y: 6.0, width: 24.0, height: 24.0))

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
            let rect = Rect(x: 100.0, y: 0.0, width: 100.0, height: BTitleBar.thickness)
            super.init(parent: titleBar, geometry: rect)

            self.renderType = .canvas
        }

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
    }

    public class Caption: BView {
        init(_ titleBar: BTitleBar) {
            let rect = Rect(x: 100.0, y: 0.0, width: 100.0, height: BTitleBar.thickness)
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

    private var _icon: Icon!
    private var _caption: Caption!

    init(_ window: BWindow) {
        _window = window

        super.init(surface: window.surface, geometry: Rect(x: 0.0, y: 0.0, width: 10.0, height: 30.0))

        // Title bar buttons.
        _closeButton = Button(to: .close, of: self)
        _minimizeButton = Button(to: .minimize, of: self)
        _maximizeOrRestoreButton = Button(to: .maximizeOrRestore, of: self)

        // Title bar button geometries.
        _closeButton.position = Point(x: 10.0, y: 3.0)
        _minimizeButton.position = Point(x: 40.0, y: 3.0)
        _maximizeOrRestoreButton.position = Point(x: 70.0, y: 3.0)

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

public class BWindowBorder: BView {
    public static var thickness: Double {
        get { 1.0 }
        set { return }
    }

    init(_ window: BWindow) {
        super.init(surface: window.surface, geometry: Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))

        self.color = Color(r: 0.0, g: 0.0, b: 0.0, a: 1.0)
        self.radius = Radius(all: 8.0)
    }
}

public class BWindowResize: BView {
    class Edge: BView {
        private let _edge: ResizeEdge
        private let _cursorShape: CursorShape
        private let _resize: BWindowResize

        init(at edge: ResizeEdge, in resize: BWindowResize) {
            _edge = edge
            _cursorShape = switch edge {
            case .topLeft: .nwseResize
            case .top: .nsResize
            case .topRight: .neswResize
            case .right: .ewResize
            case .bottomRight: .nwseResize
            case .bottom: .nsResize
            case .bottomLeft: .neswResize
            case .left: .ewResize
            }
            _resize = resize

            super.init(parent: resize, geometry: Rect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))

            self.cursorShape = _cursorShape

            self.color = .transparent
        }

        public override func pointerPressEvent(_ event: PointerEvent) {
            _resize.window.resize(_edge)
        }
    }

    public var window: BWindow
    private var _topLeft: Edge!
    private var _top: Edge!
    private var _topRight: Edge!
    private var _right: Edge!
    private var _bottomRight: Edge!
    private var _bottom: Edge!
    private var _bottomLeft: Edge!
    private var _left: Edge!

    public static var thickness: Double {
        get { 14.0 }
        set { return }
    }

    init(_ window: BWindow) {
        self.window = window

        super.init(surface: window.surface, geometry: Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))

        self.color = .transparent

        // Create edges.
        _topLeft = Edge(at: .topLeft, in: self)
        _top = Edge(at: .top, in: self)
        _topRight = Edge(at: .topRight, in: self)
        _right = Edge(at: .right, in: self)
        _bottomRight = Edge(at: .bottomRight, in: self)
        _bottom = Edge(at: .bottom, in: self)
        _bottomLeft = Edge(at: .bottomLeft, in: self)
        _left = Edge(at: .left, in: self)

        updateEdges()
    }

    public func updateEdges() {
        let thick: Double = Self.thickness

        _topLeft.geometry = Rect(
            x: 0.0, y: 0.0,
            width: thick, height: thick
        )
        _top.geometry = Rect(
            x: thick, y: 0.0,
            width: self.size.width - (thick * 2), height: thick
        )
        _topRight.geometry = Rect(
            x: self.size.width - thick, y: 0.0,
            width: thick, height: thick
        )
        _right.geometry = Rect(
            x: self.size.width - thick, y: thick,
            width: thick, height: self.size.height - (thick * 2)
        )
        _bottomRight.geometry = Rect(
            x: self.size.width - thick, y: self.size.height - thick,
            width: thick, height: thick
        )
        _bottom.geometry = Rect(
            x: thick, y: self.size.height - thick,
            width: self.size.width - (thick * 2), height: thick
        )
        _bottomLeft.geometry = Rect(
            x: 0.0, y: self.size.height - thick,
            width: thick, height: thick
        )
        _left.geometry = Rect(
            x: 0.0, y: thick,
            width: thick, height: self.size.height - (thick * 2)
        )
    }
}

public class BWindowShadow: BView {
    public static var thickness: Double {
        get { 40.0 }
        set { return }
    }

    private var _shadowInner: BView!

    init(_ window: BWindow) {
        super.init(surface: window.surface, geometry: Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))

        _shadowInner = BView(
            parent: self,
            geometry: Rect(
                x: 20.0, y: 20.0,
                width: Double(window.surfaceSize.width) - 40.0,
                height: Double(window.surfaceSize.height) - 40.0
            )
        )
        _shadowInner.color = Color(r: 0.0, g: 0.0, b: 0.0, a: 0.5)
        _shadowInner.addFilter(Blur(radius: 5.0))
        self.onResize += { [weak self] event in
            self?._shadowInner.size = Size(
                width: Double(window.surfaceSize.width) - 40.0,
                height: Double(window.surfaceSize.height) - 40.0
            )
        }

        self.color = .transparent
    }
}
