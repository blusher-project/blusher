public protocol Surface: Visible {
    associatedtype Body : Visible

    @SurfaceBuilder
    var body: Body { get }
}

public struct EmptySurface: Surface {
    public var body: some Surface {
        self
    }

    public init() {
    }
}

@resultBuilder
public struct SurfaceBuilder {
    public static func buildBlock<Content: Visible>(_ content: Content) -> Content {
        content
    }

    public static func buildBlock<C0: Visible, C1: Visible>(_ c0: C0, _ c1: C1) -> TupleVisible<(C0, C1)> {
        TupleVisible((c0, c1))
    }

    public static func buildBlock<C0: Visible, C1: Visible, C2: Visible>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleVisible<(C0, C1, C2)> {
        TupleVisible((c0, c1, c2))
    }

    public static func buildBlock<C0: Visible, C1: Visible, C2: Visible, C3: Visible>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) -> TupleVisible<(C0, C1, C2, C3)> {
        TupleVisible((c0, c1, c2, c3))
    }

    public static func buildBlock<C0: Visible, C1: Visible, C2: Visible, C3: Visible, C4: Visible>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> TupleVisible<(C0, C1, C2, C3, C4)> {
        TupleVisible((c0, c1, c2, c3, c4))
    }

    public static func buildBlock<C0: Visible, C1: Visible, C2: Visible, C3: Visible, C4: Visible, C5: Visible>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) -> TupleVisible<(C0, C1, C2, C3, C4, C5)> {
        TupleVisible((c0, c1, c2, c3, c4, c5))
    }

    public static func buildBlock<C0: Visible, C1: Visible, C2: Visible, C3: Visible, C4: Visible, C5: Visible, C6: Visible>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) -> TupleVisible<(C0, C1, C2, C3, C4, C5, C6)> {
        TupleVisible((c0, c1, c2, c3, c4, c5, c6))
    }

    public static func buildBlock<C0: Visible, C1: Visible, C2: Visible, C3: Visible, C4: Visible, C5: Visible, C6: Visible, C7: Visible>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) -> TupleVisible<(C0, C1, C2, C3, C4, C5, C6, C7)> {
        TupleVisible((c0, c1, c2, c3, c4, c5, c6, c7))
    }

    public static func buildBlock<C0: Visible, C1: Visible, C2: Visible, C3: Visible, C4: Visible, C5: Visible, C6: Visible, C7: Visible, C8: Visible>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) -> TupleVisible<(C0, C1, C2, C3, C4, C5, C6, C7, C8)> {
        TupleVisible((c0, c1, c2, c3, c4, c5, c6, c7, c8))
    }

    public static func buildBlock<C0: Visible, C1: Visible, C2: Visible, C3: Visible, C4: Visible, C5: Visible, C6: Visible, C7: Visible, C8: Visible, C9: Visible>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9) -> TupleVisible<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)> {
        TupleVisible((c0, c1, c2, c3, c4, c5, c6, c7, c8, c9))
    }
}

public struct ToplevelSurface<Content: Visible>: Surface {
    public var content: Content

    public init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    public var body: Content {
        content
    }
}

public struct SurfaceProxy {
    private weak var uiSurface: BDesktopSurface?

    init(_ uiSurface: BDesktopSurface) {
        self.uiSurface = uiSurface
    }

    public func close() {
        if let toplevel = self.uiSurface as? BToplevel {
            toplevel.close()
        }
    }

    public func startMove() {
        if let toplevel = self.uiSurface as? BToplevel {
            toplevel.move()
        }
    }

    public func startResize(_ edge: ResizeEdge) {
        if let toplevel = self.uiSurface as? BToplevel {
            toplevel.resize(edge)
        }
    }
}

enum ToplevelStorage {
    nonisolated(unsafe) static var _uiSurface: BSurface? = nil
}
