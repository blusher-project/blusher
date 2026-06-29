open class BWindow: BSurface {
    public var surfaceSize: SizeI {
        get { super.size }
        set { super.size = newValue }
    }

    public override var size: SizeI {
        get { super.size }
        set {
            super.size = newValue

            _shadow.size = Size(
                width: Float(surfaceSize.width),
                height: Float(surfaceSize.height)
            )
            _resize.geometry = _resizeGeometry
            _resize.updateEdges()
            _border.geometry = _borderGeometry
            _titleBar.geometry = _titleBarGeometry
            _body.geometry = _bodyGeometry
        }
    }

    private var _shadow: BWindowShadow!
    private var _resize: BWindowResize!
    private var _border: BWindowBorder!
    private var _titleBar: BTitleBar!
    private var _body: BView!

    public var body: BView {
        return _body
    }

    private var _wmGeometry: RectI {
        let x = Int64(_borderGeometry.x)
        let y = Int64(_borderGeometry.y)
        let width = UInt64(_borderGeometry.width)
        let height = UInt64(_borderGeometry.height)

        return RectI(x: x, y: y, width: width, height: height)
    }

    private var _inputGeometry: RectI {
        let x = Int64(_resizeGeometry.x)
        let y = Int64(_resizeGeometry.y)
        let width = UInt64(_resizeGeometry.width)
        let height = UInt64(_resizeGeometry.height)

        return RectI(x: x, y: y, width: width, height: height)
    }

    private var _resizeGeometry: Rect {
        Rect(
            x: BWindowShadow.thickness - BWindowResize.thickness,
            y: BWindowShadow.thickness - BWindowResize.thickness,
            width: Float(surfaceSize.width) - (BWindowShadow.thickness * 2) + (BWindowResize.thickness * 2),
            height: Float(surfaceSize.height) - (BWindowShadow.thickness * 2) + (BWindowResize.thickness * 2)
        )
    }

    private var _borderGeometry: Rect {
        Rect(
            x: _resizeGeometry.x + BWindowResize.thickness - BWindowBorder.thickness,
            y: _resizeGeometry.y + BWindowResize.thickness - BWindowBorder.thickness,
            width: _resizeGeometry.width - (BWindowResize.thickness * 2) + (BWindowBorder.thickness * 2),
            height: _resizeGeometry.height - (BWindowResize.thickness * 2) + (BWindowBorder.thickness * 2)
        )
    }

    private var _titleBarGeometry: Rect {
        Rect(
            x: BWindowShadow.thickness,
            y: BWindowShadow.thickness,
            width: _bodyGeometry.size.width,
            height: BTitleBar.thickness
        )
    }

    private var _bodyGeometry: Rect {
        Rect(
            x: BWindowShadow.thickness,
            y: BWindowShadow.thickness + BTitleBar.thickness,
            width: Float(surfaceSize.width) - (WindowShadow.thickness * 2),
            height: Float(surfaceSize.height) - (WindowShadow.thickness * 2) - BTitleBar.thickness
        )
    }

    public init(_ parent: BWindow? = nil) {
        super.init(role: .toplevel, parent)

        // Set window shadow.
        _shadow = BWindowShadow(self)
        _shadow.geometry = Rect(
            x: 0.0,
            y: 0.0,
            width: Float(self.surfaceSize.width),
            height: Float(self.surfaceSize.height)
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
        _body = BView(surface: self, geometry: _bodyGeometry)
    }

    public override func show() {
        super.show()

        super.wmGeometry = _wmGeometry
        super.inputGeometry = _inputGeometry
    }

    public override func resizeRequestEvent(_ event: ResizeEvent) {
        let shadowSize = Size(
            width: Float(event.size.width) + BWindowShadow.thickness * 2,
            height: Float(event.size.height) + BWindowShadow.thickness * 2
        )
        self.surfaceSize = SizeI(width: UInt64(shadowSize.width), height: UInt64(shadowSize.height))
        _shadow.size = shadowSize
        _resize.geometry = _resizeGeometry
        _resize.updateEdges()
        _border.geometry = _borderGeometry
        _titleBar.geometry = _titleBarGeometry
        _body.geometry = _bodyGeometry

        super.wmGeometry = _wmGeometry
        super.inputGeometry = _inputGeometry
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
            self.isAntialiased = true;
        }

        public override func pointerPressEvent(_ event: PointerEvent) {
            event.propagation = false
        }

        public override func pointerClickEvent(_ event: PointerEvent) {
            if event.button == .left {
                switch _action {
                case .close: _titleBar._window.close()
                case .minimize: _titleBar._window.close()   // TODO: Implementation.
                case .maximizeOrRestore: _titleBar._window.close()  // TODO: Implementation.
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

    public static var thickness: Float {
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

        super.init(surface: window, geometry: Rect(x: 0.0, y: 0.0, width: 10.0, height: 30.0))

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
            self.surface.showWindowMenu()
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
    public static var thickness: Float {
        get { 1.0 }
        set { return }
    }

    init(_ window: BWindow) {
        super.init(surface: window, geometry: Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))

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

    public static var thickness: Float {
        get { 14.0 }
        set { return }
    }

    init(_ window: BWindow) {
        self.window = window

        super.init(surface: window, geometry: Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))

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
        let thick: Float = Self.thickness

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
    public static var thickness: Float {
        get { 40.0 }
        set { return }
    }

    private var _shadowInner: BView!

    init(_ window: BWindow) {
        super.init(surface: window, geometry: Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))

        _shadowInner = BView(
            parent: self,
            geometry: Rect(
                x: 20.0, y: 20.0,
                width: Float(window.surfaceSize.width) - 40.0,
                height: Float(window.surfaceSize.height) - 40.0
            )
        )
        _shadowInner.color = Color(r: 0.0, g: 0.0, b: 0.0, a: 0.5)
        _shadowInner.addFilter(Blur(radius: 5.0))
        self.onResize += { [weak self] event in
            self?._shadowInner.size = Size(
                width: Float(window.surfaceSize.width) - 40.0,
                height: Float(window.surfaceSize.height) - 40.0
            )
        }

        self.color = .transparent
    }
}
