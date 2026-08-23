@_implementationOnly import Swingby

public enum ToplevelState {
    case maximized
    case fullscreen
    case resizing
    case activated
}

open class BToplevel: BDesktopSurface {
    private var _parent: BToplevel? = nil

    public var minimumSize: SizeI {
        get {
            if let sbSize = sb_desktop_surface_toplevel_minimum_size(super.cPointer) {
                return SizeI(
                    width: Int(sbSize.pointee.width),
                    height: Int(sbSize.pointee.height)
                )
            } else {
                return SizeI(width: 0, height: 0)
            }
        }
        set {
            var sbSize = sb_size_t(width: Float(newValue.width), height: Float(newValue.height))
            withUnsafePointer(to: &sbSize) { ptr in
                sb_desktop_surface_toplevel_set_minimum_size(super.cPointer, ptr)
            }
        }
    }

    public init(parent: BToplevel? = nil) {
        _parent = parent

        super.init(role: .toplevel)
    }

    public func close() {
        sb_desktop_surface_toplevel_close(super.cPointer)
    }

    public func minimize() {
        sb_desktop_surface_toplevel_set_minimized(super.cPointer)
    }

    public func maximize() {
        sb_desktop_surface_toplevel_set_maximized(super.cPointer)
    }

    public func restore() {
        sb_desktop_surface_toplevel_unset_maximized(super.cPointer)
    }

    public func move() {
        sb_desktop_surface_toplevel_move(super.cPointer)
    }

    public func resize(_ resizeEdge: ResizeEdge) {
        let sbEdge = switch resizeEdge {
            case .top: SB_DESKTOP_SURFACE_TOPLEVEL_RESIZE_EDGE_TOP
            case .bottom: SB_DESKTOP_SURFACE_TOPLEVEL_RESIZE_EDGE_BOTTOM
            case .left: SB_DESKTOP_SURFACE_TOPLEVEL_RESIZE_EDGE_LEFT
            case .right: SB_DESKTOP_SURFACE_TOPLEVEL_RESIZE_EDGE_RIGHT
            case .topLeft: SB_DESKTOP_SURFACE_TOPLEVEL_RESIZE_EDGE_TOP_LEFT
            case .topRight: SB_DESKTOP_SURFACE_TOPLEVEL_RESIZE_EDGE_TOP_RIGHT
            case .bottomLeft: SB_DESKTOP_SURFACE_TOPLEVEL_RESIZE_EDGE_BOTTOM_LEFT
            case .bottomRight: SB_DESKTOP_SURFACE_TOPLEVEL_RESIZE_EDGE_BOTTOM_RIGHT
        }

        sb_desktop_surface_toplevel_resize(super.cPointer, sbEdge)
    }

    public func showWindowMenu(at position: PointI) {
        var pos = sb_point_i_t(x: Int32(position.x), y: Int32(position.y))
        sb_desktop_surface_toplevel_show_window_menu(super.cPointer, &pos)
    }
}
