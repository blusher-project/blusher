@_implementationOnly import Swingby

public struct Window<Content: View>: Surface {
    private var content: Content

    @State var surfaceSize: SizeI = SizeI(width: 300, height: 200)
    // @State var resizeGeometry: Rect = Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
    @State var resizeSize: Size = Size(width: 10.0, height: 10.0)
    // @State var borderGeometry: Rect = Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
    // @State var titleBarGeometry: Rect = Rect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
    // @State var bodyGeometry: Rect = Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)

    var resizeGeometry: Rect {
        Rect(
            x: WindowShadow.thickness - WindowResize.thickness,
            y: WindowShadow.thickness - WindowResize.thickness,
            width: Double(surfaceSize.width) - (WindowShadow.thickness * 2) + (WindowResize.thickness * 2),
            height: Double(surfaceSize.height) - (WindowShadow.thickness * 2) + (WindowResize.thickness * 2)
        )
    }

    var borderGeometry: Rect {
        Rect(
            x: resizeGeometry.x + WindowResize.thickness - WindowBorder.thickness,
            y: resizeGeometry.y + WindowResize.thickness - WindowBorder.thickness,
            width: resizeGeometry.width - (WindowResize.thickness * 2) + (WindowBorder.thickness * 2),
            height: resizeGeometry.height - (WindowResize.thickness * 2) + (WindowBorder.thickness * 2)
        )
    }

    var titleBarGeometry: Rect {
        Rect(
            x: WindowShadow.thickness,
            y: WindowShadow.thickness,
            width: resizeGeometry.width - (WindowResize.thickness * 2),
            height: TitleBar.thickness
        )
    }

    var bodyGeometry: Rect {
        Rect(
            x: WindowShadow.thickness,
            y: WindowShadow.thickness + TitleBar.thickness,
            width: Double(surfaceSize.width) - (WindowShadow.thickness * 2),
            height: Double(surfaceSize.height) - (WindowShadow.thickness * 2) - TitleBar.thickness
        )
    }

    var wmGeometry: RectI {
        let x = Int(borderGeometry.x)
        let y = Int(borderGeometry.y)
        let width = Int(borderGeometry.width)
        let height = Int(borderGeometry.height)

        return RectI(x: x, y: y, width: width, height: height)
    }

    var inputGeometry: RectI {
        let x = Int(resizeGeometry.x)
        let y = Int(resizeGeometry.y)
        let width = Int(resizeGeometry.width)
        let height = Int(resizeGeometry.height)

        return RectI(x: x, y: y, width: width, height: height)
    }

    public init(@ViewBuilder _ content: () -> Content) {
        self.content = content()

        updateResizeGeometry()
        // updateBorderGeometry()
        // updateTitleBarGeometry()
        // updateBodyGeometry()
    }

    public var body: some Surface {
        ToplevelSurface {
            WindowShadow()
                .geometry(
                    Rect(
                        // TODO: The values are not accurate.
                        x: WindowShadow.thickness, y: WindowShadow.thickness,
                        width: borderGeometry.width, height: borderGeometry.height
                    )
                )
                .filters([
                    DropShadow(offset: Point(x: 0.0, y: 0.0), radius: 15.0, color: .black)
                ])
            WindowResize(size: $resizeSize)
                .geometry(resizeGeometry)
            WindowBorder()
                .geometry(borderGeometry)
            TitleBar()
                .geometry(titleBarGeometry)
            Rectangle()
                .color(Color(r: 1.0, g: 1.0, b: 1.0, a: 1.0))
                .radius(Radius(topLeft: 0.0, topRight: 0.0, bottomRight: 8.0, bottomLeft: 8.0))
                .geometry(bodyGeometry)
                .children {
                    content
                }
        }
        .size(surfaceSize)
        .wmGeometry(wmGeometry)
        .inputGeometry(inputGeometry)
        .onResizeRequest { event in
            let offsetWidth = surfaceSize.width - wmGeometry.size.width
            let offsetHeight = surfaceSize.height - wmGeometry.size.height

            surfaceSize = SizeI(
                width: Int(event.size.width) + offsetWidth,
                height: Int(event.size.height) + offsetHeight
            )

            updateResizeGeometry()
        }
    }

    private func updateResizeGeometry() {
        resizeSize = resizeGeometry.size
    }
}

    /*

    public var windowGeometry: RectI {
        get {
            return super.wmGeometry
        }
        set {
            super.wmGeometry = newValue
        }
    }

    public init() {
        super.init(role: .toplevel)

        // Decorations.
        let decoViewRect = Rect(x: 0.0, y: 0.0, width: 50.0, height: 50.0)
        _decorationView = View(parentPointer: rootViewPointer,
            surface: self,
            geometry: decoViewRect)
        _decorationView.color = Color(r: 0, g: 0, b: 0, a: 0)

        // - Shadow.
        _shadow = WindowShadow(decoration: _decorationView)

        // - Resize
        _resize = WindowResize(decoration: _decorationView)

        // - Title bar.
        _titleBar = TitleBar(decoration: _decorationView)

        rootViewColor = Color(r: 0, g: 0, b: 0, a: 0)

        // Body.
        let bodyViewRect = Rect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        _bodyView = View(parentPointer: rootViewPointer,
            surface: self,
            geometry: bodyViewRect)
        _body = Widget(parentView: _bodyView)

        updateSurfaceSize()
        updateBodyGeometry()
        updateShadowGeometry()
        updateResizeGeometry()
        updateTitleBarGeometry()
    }

    public func startMove() {
        super.move()
    }

    public func startResize(from edge: WindowResizeEdge) {
        let surfaceEdge: SurfaceResizeEdge = switch edge {
            case .top: .top
            case .bottom: .bottom
            case .left: .left
            case .right: .right
            case .topLeft: .topLeft
            case .topRight: .topRight
            case .bottomLeft: .bottomLeft
            case .bottomRight: .bottomRight
        }

        super.resize(surfaceEdge)
    }

    private func updateSurfaceSize() {
        let surfaceSize = SizeI(
            width: UInt64(body.size.width + (_shadow.thickness * 2)),
            height: UInt64(body.size.height + (_shadow.thickness * 2))
        )
        self.surfaceSize = surfaceSize

        // Fit decoration view size to surface.
        _decorationView.size = Size(
            width: Float(surfaceSize.width),
            height: Float(surfaceSize.height)
        )
    }

    private func updateBodyGeometry() {
        let newGeo = Rect(
            x: _shadow.thickness,
            y: _shadow.thickness + _titleBar.thickness,
            width: Float(surfaceSize.width) - (_shadow.thickness * 2),
            height: Float(surfaceSize.height) - (_shadow.thickness * 2) - _titleBar.thickness
        )

        _bodyView.geometry = newGeo
        _body.geometry = Rect(x: 0.0, y: 0.0, width: newGeo.width, height: newGeo.height)
    }

    private func updateWindowGeometry() {
        let newGeo = RectI(
            x: Int64(_shadow.thickness),
            y: Int64(_shadow.thickness),
            width: 100,
            height: 100
        )
        // TODO.
    }

    private func updateTitleBarGeometry() {
        _titleBar.geometry = Rect(
            x: _shadow.thickness,
            y: _shadow.thickness,
            width: _shadow.size.width,
            height: _titleBar.thickness
        )
    }

    override public func resizingEvent(_ event: ResizeEvent) {
        print("Resizing - now \(event.size.width)x\(event.size.height)")

        surfaceSize = SizeI(
            width: UInt64(event.size.width),
            height: UInt64(event.size.height)
        )

        updateShadowGeometry()
    }
}
*/
