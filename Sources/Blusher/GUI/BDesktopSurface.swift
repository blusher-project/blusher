@_implementationOnly import Swingby

open class BDesktopSurface: RoleSurface {
    public enum Role {
        case toplevel
        case popup
    }

    private var _surface: BSurface
    private var _sbDesktopSurface: OpaquePointer
    private var _wmGeometry: RectI? = nil
    private var _visible: Bool = false

    private var _resizeRequestEventListener: EventListener!
    private var _stateChangeEventListener: EventListener!

    internal var _resizeRequestHandler: ((ResizeEvent) -> Void)? = nil

    public var surface: BSurface {
        _surface
    }

    public var cPointer: OpaquePointer {
        _sbDesktopSurface
    }

    public var wmGeometry: RectI {
        get {
            // TODO: Impl.
            return RectI(x: 0, y: 0, width: 0, height: 0)
        }
        set {
            if _wmGeometry == newValue { return }

            _wmGeometry = newValue

            if _visible {
                var sbRect = sb_rect_t(
                    position: sb_point_t(
                        x: Float(newValue.position.x), y: Float(newValue.position.y)
                    ),
                    size: sb_size_t(width: Float(newValue.size.width), height: Float(newValue.size.height))
                )

                withUnsafePointer(to: &sbRect) { ptr in
                    sb_desktop_surface_set_wm_geometry(_sbDesktopSurface, ptr)
                }
            }
        }
    }

    public init(role: Role) {
        if role == .toplevel {
            _sbDesktopSurface = sb_desktop_surface_new(SB_DESKTOP_SURFACE_ROLE_TOPLEVEL)
        } else {
            _sbDesktopSurface = sb_desktop_surface_new(SB_DESKTOP_SURFACE_ROLE_POPUP)
        }

        _surface = BSurface(sbSurface: sb_desktop_surface_surface(_sbDesktopSurface))

        addEventListeners()
    }

    public func show() {
        sb_desktop_surface_show(_sbDesktopSurface)

        _visible = true

        // wmGeometry must set after .show() called.
        if _visible && _wmGeometry != nil {
            var sbRect = sb_rect_t(
                position: sb_point_t(
                    x: Float(_wmGeometry!.position.x),
                    y: Float(_wmGeometry!.position.y)
                ),
                size: sb_size_t(
                    width: Float(_wmGeometry!.size.width),
                    height: Float(_wmGeometry!.size.height)
                )
            )

            withUnsafePointer(to: &sbRect) { ptr in
                sb_desktop_surface_set_wm_geometry(_sbDesktopSurface, ptr)
            }
        }
    }

    private func addEventListeners() {
        let userData = Unmanaged.passUnretained(self).toOpaque()

        // Resize request event.
        _resizeRequestEventListener = { sbEvent, userData in
            if let userData = userData {
                let instance = Unmanaged<BDesktopSurface>.fromOpaque(userData).takeUnretainedValue()

                instance.callResizeRequestEvent(sbEvent)
            }
        } as EventListener
        sb_desktop_surface_add_event_listener(_sbDesktopSurface,
            SB_EVENT_TYPE_RESIZE_REQUEST,
            _resizeRequestEventListener,
            userData
        )

        // State change event.
        _stateChangeEventListener = { sbEvent, userData in
            if let userData = userData {
                let instance = Unmanaged<BDesktopSurface>.fromOpaque(userData).takeUnretainedValue()

                instance.callStateChangeEvent(sbEvent)
            }
        } as EventListener
        sb_desktop_surface_add_event_listener(_sbDesktopSurface,
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

    open func resizeRequestEvent(_ event: ResizeEvent) {
        // ToplevelStorage._uiSurface = self
        _resizeRequestHandler?(event)
        // ToplevelStorage._uiSurface = nil
    }

    open func stateChangeEvent(_ event: StateChangeEvent) {
        //
    }
}
