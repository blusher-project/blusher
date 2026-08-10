struct WindowResizeEdge: View {
    private let _edge: ResizeEdge
    private let _cursorShape: CursorShape

    init(at edge: ResizeEdge) {
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
    }

    var body: some View {
        Rectangle()
            .color(Color(r256: 255, g: 0, b: 0, a: 150))
            .cursorShape(_cursorShape)
            .onPointerPress { _ in
                BSurface.current?.startResize(_edge)
            }
    }
}

public struct WindowResize: View, WindowDecoration {
    @Binding var size: Size

    public static var thickness: Double {
        get { 8.0 }
        set { return }
    }

    public var body: some View {
        Rectangle()
            .color(Color(r256: 80, g: 80, b: 255, a: 255))
            .children {
                WindowResizeEdge(at: .topLeft)
                    .geometry(Rect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
                WindowResizeEdge(at: .top)
                    .geometry(Rect(
                        x: WindowResize.thickness,
                        y: 0.0,
                        width: size.width - (WindowResize.thickness * 2),
                        height: WindowResize.thickness
                    ))
            }
    }
}
