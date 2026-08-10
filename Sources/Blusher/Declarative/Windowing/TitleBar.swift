public enum TitleBarButtonAction {
    case close
    case minimize
    case maximizeRestore
}

public struct TitleBarButton: View {
    var action: TitleBarButtonAction = .close
    var buttonColor: Color!

    nonisolated(unsafe) static let closeColor = Color(r: 1.0, g: 0.0, b: 0.0, a: 1.0)
    nonisolated(unsafe) static let minimizeColor = Color(r: 1.0, g: 1.0, b: 0.0, a: 1.0)
    nonisolated(unsafe) static let maximizeRestoreColor = Color(r: 0.0, g: 1.0, b: 0.0, a: 1.0)

    public init(action: TitleBarButtonAction) {
        self.action = action

        switch action {
        case .close:
            buttonColor = TitleBarButton.closeColor
        case .minimize:
            buttonColor = TitleBarButton.minimizeColor
        case .maximizeRestore:
            buttonColor = TitleBarButton.maximizeRestoreColor
        }

        // size = Size(width: 24.0, height: 24.0)
    }

    public var body: some View {
        Rectangle()
            .color(buttonColor)
            .radius(Radius(all: 50.0))
            .onPointerPress { event in
                event.propagation = false
            }
            .onPointerClick { event in
                switch action {
                case .close:
                    BSurface.current?.close()
                    break
                case .minimize:
                    // window.minimize()
                    break
                case .maximizeRestore:
                    // window.maximizeRestore()
                    break
                }
            }
    }
}

public struct TitleBar: View, WindowDecoration {
    public static var thickness: Double {
        get { 30.0 }
        set { return }
    }

    @State private var _pressed: Bool = false

    public var body: some View {
        Rectangle()
            .color(Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0))
            .radius(Radius(topLeft: 8.0, topRight: 8.0, bottomRight: 0.0, bottomLeft: 0.0))
            .onPointerPress { _ in
                _pressed = true
            }
            .onPointerMove { _ in
                if _pressed == true {
                    BSurface.current?.startMove()
                    _pressed = false
                }
            }
            .children {
                TitleBarButton(action: .close)
                    .geometry(Rect(x: 3.0, y: 3.0, width: 24.0, height: 24.0))
                TitleBarButton(action: .minimize)
                    .geometry(Rect(x: 30.0, y: 3.0, width: 24.0, height: 24.0))
                TitleBarButton(action: .maximizeRestore)
                    .geometry(Rect(x: 60.0, y: 3.0, width: 24.0, height: 24.0))
            }
    }
}

/*
public class TitleBar: Widget, WindowDecoration {
    public var thickness: Float = 30.0

    private var _pressed: Bool = false

    private var _closeButton: TitleBarButton!
    private var _minimizeButton: TitleBarButton!
    private var _maximizeRestoreButton: TitleBarButton!

    public init(decoration: UIView) {
        super.init(parentView: decoration)

        // Title bar buttons.
        _closeButton = TitleBarButton(action: .close, parent: self)
        _minimizeButton = TitleBarButton(action: .minimize, parent: self)
        _maximizeRestoreButton = TitleBarButton(action: .maximizeRestore, parent: self)

        _closeButton.position = Point(x: 3.0, y: 3.0)
        _minimizeButton.position = Point(x: 30.0, y: 3.0)
        _maximizeRestoreButton.position = Point(x: 60.0, y: 3.0)

        color = Color(r: 128, g: 128, b: 128, a: 255)
    }

    public override func pointerPressEvent(_ event: PointerEvent) {
        _pressed = true
        print("TitleBar - pointerPressEvent")

        super.pointerPressEvent(event)
    }

    public override func pointerMoveEvent(_ event: PointerEvent) {
        if _pressed {
            // window.startMove()
            _pressed = false
        }

        // event.propagation = false

        super.pointerMoveEvent(event)
    }
}
*/
