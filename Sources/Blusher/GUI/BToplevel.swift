@_implementationOnly import Swingby

public enum ToplevelState {
    case maximized
    case fullscreen
    case resizing
    case activated
}

open class BToplevel: SurfaceRole {

    //==============================
    // Private Stored Properties
    //==============================
    private var _sbToplevel: OpaquePointer
    private var _surface: BSurface
    private var _parent: BToplevel? = nil

    private var _wmGeometry: RectI? = nil

    private var _resizeRequestEventListener: EventListener!
    private var _stateChangeEventListener: EventListener!

    //==============================
    // Internal Computed Properties
    //==============================
    internal var cPointer: OpaquePointer {
        _sbToplevel
    }

    //==============================
    // Public Computed Properties
    //==============================

    public var minimumSize: SizeI {
        get {
            let sbSize = sb_toplevel_minimum_size(_sbToplevel)
            return SizeI(
                width: Int(sbSize.width),
                height: Int(sbSize.height)
            )
        }
        set {
            let sbSize = sb_size_i_t(width: Int32(newValue.width), height: Int32(newValue.height))
            sb_toplevel_set_minimum_size(_sbToplevel, sbSize)
        }
    }

    public var wmGeometry: RectI? {
        get { _wmGeometry }
        set {
            _wmGeometry = newValue
            if _wmGeometry != nil {
                sb_toplevel_set_wm_geometry(_sbToplevel, rectIToSbRectI(_wmGeometry!))
            }
        }
    }

    //============================================
    // Public Computed Properties - SurfaceRole
    //============================================

    public var surface: BSurface {
        _surface
    }

    public var roleName: String {
        "toplevel"
    }

    //=======================
    // Public Initializer
    //=======================

    public init(parent: BToplevel? = nil) {
        _sbToplevel = sb_toplevel_new()

        _surface = BSurface(sbSurface: sb_toplevel_surface(_sbToplevel))

        _parent = parent

        self.addEventListeners()
    }

    //===================
    // Public Methods
    //===================

    public func show() {
        sb_toplevel_show(_sbToplevel)
    }

    public func hide() {
        sb_toplevel_hide(_sbToplevel)
    }

    public func close() {
        sb_toplevel_close(_sbToplevel)
    }

    public func minimize() {
        sb_toplevel_set_minimized(_sbToplevel)
    }

    public func maximize() {
        sb_toplevel_set_maximized(_sbToplevel)
    }

    public func restore() {
        sb_toplevel_unset_maximized(_sbToplevel)
    }

    public func move() {
        sb_toplevel_move(_sbToplevel)
    }

    public func resize(_ resizeEdge: ResizeEdge) {
        let sbEdge = switch resizeEdge {
            case .top: SB_TOPLEVEL_RESIZE_EDGE_TOP
            case .bottom: SB_TOPLEVEL_RESIZE_EDGE_BOTTOM
            case .left: SB_TOPLEVEL_RESIZE_EDGE_LEFT
            case .right: SB_TOPLEVEL_RESIZE_EDGE_RIGHT
            case .topLeft: SB_TOPLEVEL_RESIZE_EDGE_TOP_LEFT
            case .topRight: SB_TOPLEVEL_RESIZE_EDGE_TOP_RIGHT
            case .bottomLeft: SB_TOPLEVEL_RESIZE_EDGE_BOTTOM_LEFT
            case .bottomRight: SB_TOPLEVEL_RESIZE_EDGE_BOTTOM_RIGHT
        }

        sb_toplevel_resize(_sbToplevel, sbEdge)
    }

    public func showWindowMenu(at position: PointI) {
        let pos = sb_point_i_t(x: Int32(position.x), y: Int32(position.y))
        sb_toplevel_show_window_menu(_sbToplevel, pos)
    }

    //====================
    // Private Methods
    //====================
    private func addEventListeners() {
        let userData = Unmanaged.passUnretained(self).toOpaque()

        // Resize request event.
        _resizeRequestEventListener = { sbEvent, userData in
            if let userData = userData {
                let instance = Unmanaged<BToplevel>.fromOpaque(userData).takeUnretainedValue()

                instance.callResizeRequestEvent(sbEvent)
            }
        } as EventListener
        sb_toplevel_add_event_listener(_sbToplevel,
            SB_EVENT_TYPE_RESIZE_REQUEST,
            _resizeRequestEventListener,
            userData
        )

        // State change event.
        _stateChangeEventListener = { sbEvent, userData in
            if let userData = userData {
                let instance = Unmanaged<BToplevel>.fromOpaque(userData).takeUnretainedValue()

                instance.callStateChangeEvent(sbEvent)
            }
        } as EventListener
        sb_toplevel_add_event_listener(_sbToplevel,
            SB_EVENT_TYPE_STATE_CHANGE,
            _stateChangeEventListener,
            userData
        )
    }

    private func callResizeRequestEvent(_ sbEvent: UnsafeMutablePointer<sb_event_t>?) {
        let sbOldSize = sb_event_resize_old_size(sbEvent)
        let sbSize = sb_event_resize_size(sbEvent)

        let oldSize = Size(
            width: Double(sbOldSize?.pointee.width ?? 0.0),
            height: Double(sbOldSize?.pointee.height ?? 0.0)
        )
        let size = Size(
            width: Double(sbSize?.pointee.width ?? 0.0),
            height: Double(sbSize?.pointee.height ?? 0.0)
        )

        let event = ResizeEvent(oldSize: oldSize, size: size)
        resizeRequestEvent(event)
    }

    private func callStateChangeEvent(_ sbEvent: UnsafeMutablePointer<sb_event_t>?) {
        let sbState = UInt32(sb_event_state_change_state(sbEvent))
        let state: ToplevelState = switch sbState {
        case SB_DESKTOP_SURFACE_TOPLEVEL_STATE_MAXIMIZED.rawValue: .maximized
        default: .activated
        }
        let sbSize = sb_event_state_change_size(sbEvent)
        let sbValue = sb_event_state_change_value(sbEvent)
        let event = StateChangeEvent(
            state: state,
            on: sbValue,
            SizeI(width: Int(sbSize.width), height: Int(sbSize.height))
        )
        stateChangeEvent(event)
    }

    //===============
    // Open Events
    //===============
    open func resizeRequestEvent(_ event: ResizeEvent) {
    }

    open func stateChangeEvent(_ event: StateChangeEvent) {
    }
}
