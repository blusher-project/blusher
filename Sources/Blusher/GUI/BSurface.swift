@_implementationOnly import Swingby

public enum SurfaceRole {
    case toplevel
    case popup
}

public enum ResizeEdge {
    case top
    case bottom
    case left
    case right
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

open class BSurface {
    private var _sbDesktopSurface: OpaquePointer? = nil
    private var _parent: BSurface? = nil
    private var _wmGeometry: RectI? = nil
    private var _scale: Int = 1
    private var _visible: Bool = false

    private var _resizeRequestEventListener: EventListener!
    private var _preferredScaleEventListener: EventListener!
    private var _timeoutEventListener: EventListener!

    internal var _resizeRequestHandler: ((ResizeEvent) -> Void)? = nil
    internal var _timeoutHandler: ((TimerEvent) -> Void)? = nil

    public var onTimeout: EventHandler<TimerEvent>? = nil

    internal var sbDesktopSurface: OpaquePointer? {
        _sbDesktopSurface
    }

    internal var sbSurface: OpaquePointer? {
        sb_desktop_surface_surface(_sbDesktopSurface)
    }

    // TODO: Change this to internal when the test done.
    public var rootViewPointer: OpaquePointer {
        get {
            let sbSurface = sb_desktop_surface_surface(_sbDesktopSurface)
            let sbRootView = sb_surface_root_view(sbSurface)

            return sbRootView!
        }
    }

    internal var cPointer: OpaquePointer? {
        self._sbDesktopSurface
    }

    public var children: [BView] = []

    public var rootViewColor: Color {
        get {
            // TODO: Impl.
            return Color(r: 1.0, g: 1.0, b: 1.0, a: 1.0)
        }
        set(newValue) {
            var sbColor = sb_color_t(
                r: newValue.r,
                g: newValue.g,
                b: newValue.b,
                a: newValue.a
            )

            withUnsafePointer(to: &sbColor) { ptr in
                sb_view_set_color(rootViewPointer, ptr)
            }
        }
    }

    public var size: SizeI {
        get {
            let sbSurface = sb_desktop_surface_surface(_sbDesktopSurface)
            let sbSize = UnsafeMutablePointer(mutating: sb_surface_size(sbSurface))

            let width: Float = sb_size_width(sbSize)
            let height: Float = sb_size_height(sbSize)

            return SizeI(width: UInt64(width), height: UInt64(height))
        }
        set {
            let sbSurface = sb_desktop_surface_surface(_sbDesktopSurface)

            var sbSize = sb_size_t(
                width: Float(newValue.width),
                height: Float(newValue.height)
            )

            withUnsafePointer(to: &sbSize) { ptr in
                sb_surface_set_size(sbSurface, ptr)
            }
        }
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

    public var inputGeometry: RectI {
        get {
            // TODO: Impl.
            return RectI(x: 0, y: 0, width: 0, height: 0)
        }
        set {
            var sbRect = sb_rect_t(
                position: sb_point_t(
                    x: Float(newValue.position.x), y: Float(newValue.position.y)
                ),
                size: sb_size_t(width: Float(newValue.size.width), height: Float(newValue.size.height))
            )

            withUnsafeMutablePointer(to: &sbRect) { ptr in
                let sbSurface = sb_desktop_surface_surface(_sbDesktopSurface)
                sb_surface_set_input_geometry(sbSurface, ptr)
            }
        }
    }

    public var scale: Int {
        get {
            _scale
        }
        set {
            if _scale == newValue { return }
            _scale = newValue

            let sbSurface = sb_desktop_surface_surface(_sbDesktopSurface)
            sb_surface_set_scale(sbSurface, UInt32(_scale))
        }
    }

    public let role: SurfaceRole

    public init(role: SurfaceRole, _ parent: BSurface? = nil) {
        self.role = role
        _parent = parent

        let sbRole = role == .toplevel
            ? SB_DESKTOP_SURFACE_ROLE_TOPLEVEL
            : SB_DESKTOP_SURFACE_ROLE_POPUP
        _sbDesktopSurface = sb_desktop_surface_new(sbRole)

        if _parent != nil {
            sb_desktop_surface_set_parent(self.sbDesktopSurface, parent!.sbDesktopSurface)
        }

        rootViewColor = Color(r: 0.0, g: 0.0, b: 0.0, a: 0.0)

        addEventListeners()
    }

    public func update() {
        sb_surface_update(self.sbSurface)
    }

    public func close() {
        if role == .toplevel {
            sb_desktop_surface_toplevel_close(_sbDesktopSurface)
        }
    }

    public func move() {
        sb_desktop_surface_toplevel_move(_sbDesktopSurface)
    }

    public func resize(_ resizeEdge: ResizeEdge) {
        if role != .toplevel {
            return
        }

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

        sb_desktop_surface_toplevel_resize(_sbDesktopSurface, sbEdge)
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

        // Resizing event.
        _resizeRequestEventListener = { sbEvent, userData in
            if let userData = userData {
                let instance = Unmanaged<BSurface>.fromOpaque(userData).takeUnretainedValue()

                instance.callResizingEvent(sbEvent)
            }
        } as EventListener
        sb_desktop_surface_add_event_listener(_sbDesktopSurface,
            SB_EVENT_TYPE_RESIZE_REQUEST,
            _resizeRequestEventListener,
            userData
        )

        // Preferred scale event.
        _preferredScaleEventListener = { sbEvent, userData in
            if let userData = userData {
                let instance = Unmanaged<BSurface>.fromOpaque(userData).takeUnretainedValue()

                instance.callPreferredScaleEvent(sbEvent)
            }
        } as EventListener
        sb_surface_add_event_listener(sb_desktop_surface_surface(_sbDesktopSurface),
            SB_EVENT_TYPE_PREFERRED_SCALE,
            _preferredScaleEventListener,
            userData
        )

        // Timeout event.
        _timeoutEventListener = { sbEvent, userData in
            if let userData = userData {
                let instance = Unmanaged<BSurface>.fromOpaque(userData).takeUnretainedValue()

                instance.callTimeoutEvent(sbEvent)
            }
        } as EventListener
        sb_surface_add_event_listener(sb_desktop_surface_surface(_sbDesktopSurface),
            SB_EVENT_TYPE_TIMEOUT,
            _timeoutEventListener,
            userData
        )
    }

    private func callResizingEvent(_ sbEvent: UnsafeMutablePointer<sb_event_t>?) {
        let sbOldSize = sb_event_resize_old_size(sbEvent)
        let sbSize = sb_event_resize_size(sbEvent)

        let oldSize = Size(
            width: sb_size_width(UnsafeMutablePointer(mutating: sbOldSize)),
            height: sb_size_height(UnsafeMutablePointer(mutating: sbOldSize))
        )
        let size = Size(
            width: sb_size_width(UnsafeMutablePointer(mutating: sbSize)),
            height: sb_size_height(UnsafeMutablePointer(mutating: sbSize))
        )

        let event = ResizeEvent(oldSize: oldSize, size: size)
        resizeRequestEvent(event)
    }

    private func callPreferredScaleEvent(_ sbEvent: UnsafeMutablePointer<sb_event_t>?) {
        let sbScale = sb_event_scale_scale(sbEvent)
        let event = ScaleEvent(scale: Int(sbScale))
        preferredScaleEvent(event)
    }

    private func callTimeoutEvent(_ sbEvent: UnsafeMutablePointer<sb_event_t>?) {
        let id = sb_event_timer_id(sbEvent)
        let interval = sb_event_timer_interval(sbEvent)
        let event = TimerEvent(interval: Int(interval), repeats: false)
        event.id = Int(id)
        timeoutEvent(event)
    }

    open func resizeRequestEvent(_ event: ResizeEvent) {
        ToplevelStorage._uiSurface = self
        _resizeRequestHandler?(event)
        ToplevelStorage._uiSurface = nil
    }

    open func preferredScaleEvent(_ event: ScaleEvent) {
        ToplevelStorage._uiSurface = self
        // _preferredScaleHandler?(event)
        self.scale = event.scale
        ToplevelStorage._uiSurface = nil
    }

    open func timeoutEvent(_ event: TimerEvent) {
        ToplevelStorage._uiSurface = self
        _timeoutHandler?(event)
        self.onTimeout?.invoke(event)
        ToplevelStorage._uiSurface = nil
    }

    public static var current: SurfaceProxy? {
        guard let uiSurface = ToplevelStorage._uiSurface else { return nil }
        return SurfaceProxy(uiSurface)
    }
}
