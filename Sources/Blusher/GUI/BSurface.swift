@_implementationOnly import Swingby

public protocol RoleSurface {
    var surface: BSurface { get }
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
    private var _sbSurface: OpaquePointer
    private var _role: (any RoleSurface)? = nil
    private var _size: SizeI = SizeI(width: 10, height: 10)
    private var _scale: Float = 1.0

    private var _preferredScaleEventListener: EventListener!
    private var _timeoutEventListener: EventListener!

    internal var _timeoutHandler: ((TimerEvent) -> Void)? = nil

    public var onTimeout: EventHandler<TimerEvent>? = nil

    // TODO: Change this to internal when the test done.
    public var rootViewPointer: OpaquePointer {
        get {
            let sbRootView = sb_surface_root_view(_sbSurface)

            return sbRootView!
        }
    }

    public var cPointer: OpaquePointer {
        _sbSurface
    }

    public var children: [BView] = []

    public var rootViewColor: Color {
        get {
            // TODO: Impl.
            return Color(r: 1.0, g: 1.0, b: 1.0, a: 1.0)
        }
        set {
            let sbColor = sb_color_t(
                r: newValue.r,
                g: newValue.g,
                b: newValue.b,
                a: newValue.a
            )

            sb_view_set_color(rootViewPointer, sbColor)
        }
    }

    public var size: SizeI {
        get {
            return _size
        }
        set {
            _size = newValue

            let sbSize = sb_size_i_t(
                width: Int32(newValue.width),
                height: Int32(newValue.height)
            )

            sb_surface_set_size(_sbSurface, sbSize)
        }
    }

    public var inputGeometry: RectI {
        get {
            // TODO: Impl.
            return RectI(x: 0, y: 0, width: 0, height: 0)
        }
        set {
            let sbRect = sb_rect_t(
                position: sb_point_t(
                    x: Float(newValue.position.x), y: Float(newValue.position.y)
                ),
                size: sb_size_t(width: Float(newValue.size.width), height: Float(newValue.size.height))
            )

            sb_surface_set_input_geometry(_sbSurface, sbRect)
        }
    }

    public var scale: Float {
        get {
            _scale
        }
        set {
            if _scale == newValue { return }
            _scale = newValue

            sb_surface_set_scale(_sbSurface, _scale)
        }
    }

    public init() {
        _sbSurface = sb_surface_new()

        rootViewColor = Color(r: 0.0, g: 0.0, b: 0.0, a: 0.0)

        addEventListeners()
    }

    internal init(sbSurface: OpaquePointer) {
        _sbSurface = sbSurface

        rootViewColor = .transparent

        addEventListeners()
    }

    public func update() {
        sb_surface_update(_sbSurface)
    }

    private func addEventListeners() {
        let userData = Unmanaged.passUnretained(self).toOpaque()

        // Preferred scale event.
        _preferredScaleEventListener = { sbEvent, userData in
            if let userData = userData {
                let instance = Unmanaged<BSurface>.fromOpaque(userData).takeUnretainedValue()

                instance.callPreferredScaleEvent(sbEvent)
            }
        } as EventListener
        sb_surface_add_event_listener(_sbSurface,
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
        sb_surface_add_event_listener(_sbSurface,
            SB_EVENT_TYPE_TIMEOUT,
            _timeoutEventListener,
            userData
        )
    }

    private func callPreferredScaleEvent(_ sbEvent: UnsafeMutablePointer<sb_event_t>?) {
        let sbScale = sb_event_scale_scale(sbEvent)
        let event = ScaleEvent(scale: Float(sbScale))
        preferredScaleEvent(event)
    }

    private func callTimeoutEvent(_ sbEvent: UnsafeMutablePointer<sb_event_t>?) {
        let id = sb_event_timer_id(sbEvent)
        let interval = sb_event_timer_interval(sbEvent)
        let event = TimerEvent(interval: Int(interval), repeats: false)
        event.id = Int(id)
        timeoutEvent(event)
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
        // guard let uiSurface = ToplevelStorage._uiSurface else { return nil }
        return nil // SurfaceProxy(uiSurface)
    }
}
