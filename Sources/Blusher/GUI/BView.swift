@_implementationOnly import Swingby

public enum ViewRenderType {
    case singleColor
    case image
    case text
    case canvas
}

open class BView {
    private var _sbView: OpaquePointer?
    private var _surface: BSurface!
    private var _parent: BView?
    private var _children: [BView] = []

    private var _renderType: ViewRenderType = .singleColor
    private var _clip: Bool = false
    private var _color: Color = Color(r: 0.0, g: 0.0, b: 0.0, a: 0.0)
    private var _image: ImageHandle? = nil
    private var _textLayout: TextLayout? = nil
    private var _geometry: Rect = Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
    private var _cursorShape: CursorShape = .default
    private var _layout: (any Layout)? = nil
    private var _layoutConstraint: LayoutConstraint? = nil

    private var _pointerEnterEventListener: EventListener!
    private var _pointerLeaveEventListener: EventListener!
    private var _pointerMoveEventListener: EventListener!
    private var _pointerPressEventListener: EventListener!
    private var _pointerReleaseEventListener: EventListener!
    private var _pointerClickEventListener: EventListener!
    private var _resizeEventListener: EventListener!
    private var _paintEventListener: EventListener!

    internal var _pointerEnterHandler: ((PointerEvent) -> Void)? = nil
    internal var _pointerLeaveHandler: ((PointerEvent) -> Void)? = nil
    internal var _pointerMoveHandler: ((PointerEvent) -> Void)? = nil
    internal var _pointerPressHandler: ((PointerEvent) -> Void)? = nil
    internal var _pointerReleaseHandler: ((PointerEvent) -> Void)? = nil
    internal var _pointerClickHandler: ((PointerEvent) -> Void)? = nil
    internal var _resizeHandler: ((ResizeEvent) -> Void)? = nil
    internal var _paintHandler: ((Event) -> Void)? = nil

    public var onPointerClick: EventHandler<PointerEvent>? = nil
    public var onResize: EventHandler<ResizeEvent>? = nil

    internal var cPointer: OpaquePointer? {
        _sbView
    }

    public var parent: BView? {
        _parent
    }

    public var children: [BView] {
        _children
    }

    public var clip: Bool {
        get { _clip }
        set {
            if _clip == newValue {
                return
            }
            _clip = newValue

            sb_view_set_clip(_sbView, newValue)
        }
    }

    public var renderType: ViewRenderType {
        get { _renderType }
        set {
            if _renderType == newValue {
                return
            }
            _renderType = newValue

            let sbType = switch _renderType {
                case .singleColor: SB_VIEW_RENDER_TYPE_SINGLE_COLOR
                case .image: SB_VIEW_RENDER_TYPE_IMAGE
                case .text: SB_VIEW_RENDER_TYPE_GLYPHS
                case .canvas: SB_VIEW_RENDER_TYPE_CANVAS
            }
            sb_view_set_render_type(_sbView, sbType)
        }
    }

    public var color: Color {
        get {
            return _color
        }
        set(newValue) {
            // TODO: Optimization.
            if newValue == .transparent {
            } else if _color == newValue {
                return
            }

            _color = newValue

            var sbColor = sb_color_t(
                r: newValue.r,
                g: newValue.g,
                b: newValue.b,
                a: newValue.a
            )

            withUnsafePointer(to: &sbColor) { ptr in
                sb_view_set_color(_sbView, ptr)
            }
        }
    }

    public var image: ImageHandle? {
        get { _image }
        set {
            if let image = newValue {
                _image = image

                sb_view_set_image(_sbView, image._sbImage)
            } else {
                _image = nil

                sb_view_set_image(_sbView, nil)
            }
        }
    }

    public var canvas: Canvas? {
        if let sbCanvas = sb_view_canvas(_sbView) {
            let canvas = Canvas(sbCanvas)
            return canvas
        }
        return nil
    }

    public var textLayout: TextLayout? {
        get { _textLayout }
        set {
            _textLayout = newValue

            if let layout = newValue {
                sb_view_set_glyph_layout(_sbView, layout._sbLayout)
            } else {
                _textLayout = nil
            }
        }
    }

    public var geometry: Rect {
        get {
            let sbRect = sb_view_geometry(_sbView)
            let x = sbRect!.pointee.position.x
            let y = sbRect!.pointee.position.y
            let width = sbRect!.pointee.size.width
            let height = sbRect!.pointee.size.height

            return Rect(x: x, y: y, width: width, height: height)
        }
        set {
            if _geometry == newValue {
                return
            }

            _geometry = newValue

            var sbRect = sb_rect_t(
                position: sb_point_t(x: newValue.position.x, y: newValue.position.y),
                size: sb_size_t(width: newValue.size.width, height: newValue.size.height)
            )

            withUnsafePointer(to: &sbRect) { ptr in
                sb_view_set_geometry(_sbView, ptr)
            }

            layingOut()
        }
    }

    public var position: Point {
        get {
            return Point(x: geometry.position.x, y: geometry.position.y)
        }
        set {
            let geo = Rect(
                x: newValue.x, y: newValue.y,
                width: geometry.size.width, height: geometry.size.height
            )
            geometry = geo
        }
    }

    public var size: Size {
        get {
            return Size(width: geometry.size.width, height: geometry.size.height)
        }
        set(newValue) {
            let geo = Rect(
                x: geometry.position.x, y: geometry.position.y,
                width: newValue.width, height: newValue.height
            )
            geometry = geo
        }
    }

    public var absolutePosition: Point {
        let sbPoint = sb_view_absolute_position(_sbView)
        return Point(x: sbPoint.x, y: sbPoint.y)
    }

    public var radius: Radius {
        get {
            // TODO: Implement!
            return Radius(all: 0.0)
        }
        set {
            var sbRadius = sb_view_radius_t(
                top_left: newValue.topLeft,
                top_right: newValue.topRight,
                bottom_right: newValue.bottomRight,
                bottom_left: newValue.bottomLeft
            )

            withUnsafePointer(to: &sbRadius) { ptr in
                sb_view_set_radius(_sbView, ptr)
            }
        }
    }

    public var cursorShape: CursorShape {
        get {
            _cursorShape
        }
        set {
            if _cursorShape == newValue {
                return
            }

            _cursorShape = newValue

            let sbCursorShape = CursorShape.toSwingbyCursorShape(newValue)
            sb_view_set_cursor_shape(_sbView, sbCursorShape)
        }
    }

    public var surface: BSurface {
        get {
            return _surface
        }
    }

    public var layout: (any Layout)? {
        get { _layout }
        set {
            if newValue != nil {
                _layout = newValue
                _layout?.attach(to: self)
                self.layingOut()
            } else {
                _layout?.detach()
                _layout = nil
            }
        }
    }

    public var layoutConstraint: LayoutConstraint? {
        get { _layoutConstraint }
        set { _layoutConstraint = newValue }
    }

    public init(parent: BView, geometry: Rect) {
        let sbParent = parent._sbView
        var sbRect = sb_rect_t(
            position: sb_point_t(x: geometry.x, y: geometry.y),
            size: sb_size_t(width: geometry.width, height: geometry.height)
        )

        withUnsafePointer(to: &sbRect) { ptr in
            _sbView = sb_view_new(sbParent, ptr)
        }

        _surface = parent._surface
        _surface.children.append(self)
        _parent = parent
        _parent?._children.append(self)
        // For initial.
        _parent?.layingOut()

        clip = true

        addEventListeners()
    }

    public init(surface: BSurface, geometry: Rect) {
        var sbRect = sb_rect_t(
            position: sb_point_t(x: geometry.x, y: geometry.y),
            size: sb_size_t(width: geometry.width, height: geometry.height)
        )

        withUnsafePointer(to: &sbRect) { ptr in
            _sbView = sb_view_new(surface.rootViewPointer, ptr)
        }

        _surface = surface
        _surface.children.append(self)
        _parent = nil

        clip = true

        addEventListeners()
    }

    public func addFilter(_ filter: Filter) {
        let sbFilterType = switch filter.type {
            case .blur:
                SB_FILTER_TYPE_BLUR
            case .dropShadow:
                SB_FILTER_TYPE_DROP_SHADOW
        }

        let sbFilter = sb_filter_new(sbFilterType)

        if let blur = filter as? Blur {
            sb_filter_blur_set_radius(sbFilter, blur.radius)

            sb_view_add_filter(_sbView, sbFilter)
        } else if let dropShadow = filter as? DropShadow {
            var offset = sb_point_t(x: dropShadow.offset.x, y: dropShadow.offset.y)
            var color = sb_color_t(
                r: dropShadow.color.r,
                g: dropShadow.color.g,
                b: dropShadow.color.b,
                a: dropShadow.color.a
            )

            withUnsafePointer(to: &offset) { ptr in
                sb_filter_drop_shadow_set_offset(sbFilter, ptr)
            }
            sb_filter_drop_shadow_set_radius(sbFilter, dropShadow.radius)
            withUnsafePointer(to: &color) { ptr in
                sb_filter_drop_shadow_set_color(sbFilter, ptr)
            }

            sb_view_add_filter(_sbView, sbFilter)
        }
    }

    internal func layingOut() {
        // Calculate the child nodes based on the layout.
        if let layout = _layout {
            layout.constraintFunction()
        }
    }

    private func addEventListeners() {
        let userData = Unmanaged.passUnretained(self).toOpaque()

        // Pointer enter event.
        _pointerEnterEventListener = { sbEvent, userData in
            if let userData = userData {
                let instance = Unmanaged<BView>.fromOpaque(userData).takeUnretainedValue()

                instance.callPointerEnterEvent(sbEvent)
            }
        } as EventListener
        sb_view_add_event_listener(_sbView, SB_EVENT_TYPE_POINTER_ENTER,
            _pointerEnterEventListener, userData)

        // Pointer leave event.
        _pointerLeaveEventListener = { sbEvent, userData in
            if let userData = userData {
                let instance = Unmanaged<BView>.fromOpaque(userData).takeUnretainedValue()

                instance.callPointerLeaveEvent(sbEvent)
            }
        } as EventListener
        sb_view_add_event_listener(_sbView, SB_EVENT_TYPE_POINTER_LEAVE,
            _pointerLeaveEventListener, userData)

        // Pointer move event.
        _pointerMoveEventListener = { sbEvent, userData in
            if let userData = userData {
                let instance = Unmanaged<BView>.fromOpaque(userData).takeUnretainedValue()

                instance.callPointerMoveEvent(sbEvent)
            }
        } as EventListener
        sb_view_add_event_listener(_sbView, SB_EVENT_TYPE_POINTER_MOVE,
            _pointerMoveEventListener, userData)

        // Pointer press event.
        _pointerPressEventListener = { sbEvent, userData in
            if let userData = userData {
                let instance = Unmanaged<BView>.fromOpaque(userData).takeUnretainedValue()

                instance.callPointerPressEvent(sbEvent)
            }
        } as EventListener
        sb_view_add_event_listener(_sbView, SB_EVENT_TYPE_POINTER_PRESS,
            _pointerPressEventListener, userData)

        // Pointer release event.
        _pointerReleaseEventListener = { sbEvent, userData in
            if let userData = userData {
                let instance = Unmanaged<BView>.fromOpaque(userData).takeUnretainedValue()

                instance.callPointerReleaseEvent(sbEvent)
            }
        } as EventListener
        sb_view_add_event_listener(_sbView, SB_EVENT_TYPE_POINTER_RELEASE,
            _pointerReleaseEventListener, userData)

        // Pointer click event.
        _pointerClickEventListener = { sbEvent, userData in
            if let userData = userData {
                let instance = Unmanaged<BView>.fromOpaque(userData).takeUnretainedValue()

                instance.callPointerClickEvent(sbEvent)
            }
        } as EventListener
        sb_view_add_event_listener(_sbView, SB_EVENT_TYPE_POINTER_CLICK,
            _pointerClickEventListener, userData)

        // Resize event.
        _resizeEventListener = { sbEvent, userData in
            if let userData = userData {
                let instance = Unmanaged<BView>.fromOpaque(userData).takeUnretainedValue()

                instance.callResizeEvent(sbEvent)
            }
        } as EventListener
        sb_view_add_event_listener(_sbView, SB_EVENT_TYPE_RESIZE,
            _resizeEventListener, userData)

        // Paint event.
        _paintEventListener = { sbEvent, userData in
            if let userData = userData {
                let instance = Unmanaged<BView>.fromOpaque(userData).takeUnretainedValue()

                instance.callPaintEvent(sbEvent)
            }
        }
        sb_view_add_event_listener(_sbView, SB_EVENT_TYPE_PAINT,
            _paintEventListener, userData)
    }

    private func callPointerEnterEvent(_ sbEvent: UnsafeMutablePointer<sb_event_t>?) {
        let sbPos = sb_event_pointer_position(sbEvent)
        let x = sb_point_x(sbPos)
        let y = sb_point_y(sbPos)
        let event = PointerEvent(type: .pointerEnter)
        event.position.x = x
        event.position.y = y
        pointerEnterEvent(event)
    }

    private func callPointerLeaveEvent(_ sbEvent: UnsafeMutablePointer<sb_event_t>?) {
        let sbPos = sb_event_pointer_position(sbEvent)
        let x = sb_point_x(sbPos)
        let y = sb_point_y(sbPos)
        let event = PointerEvent(type: .pointerLeave)
        event.position.x = x
        event.position.y = y
        pointerLeaveEvent(event)
    }

    private func callPointerMoveEvent(_ sbEvent: UnsafeMutablePointer<sb_event_t>?) {
        let sbPos = sb_event_pointer_position(sbEvent)
        let x = sb_point_x(sbPos)
        let y = sb_point_y(sbPos)
        let event = PointerEvent(type: .pointerMove)
        event.position.x = x
        event.position.y = y
        pointerMoveEvent(event)
    }

    private func callPointerPressEvent(_ sbEvent: UnsafeMutablePointer<sb_event_t>?) {
        let sbButton = sb_event_pointer_button(sbEvent)
        let button: PointerButton = switch sbButton {
            case SB_POINTER_BUTTON_NONE: .none
            case SB_POINTER_BUTTON_LEFT: .left
            case SB_POINTER_BUTTON_RIGHT: .right
            case SB_POINTER_BUTTON_MIDDLE: .middle
            default: .none
        }

        let sbPos = sb_event_pointer_position(sbEvent)
        let x = sb_point_x(sbPos)
        let y = sb_point_y(sbPos)

        let event = PointerEvent(type: .pointerPress)
        event.button = button
        event.position.x = x
        event.position.y = y
        event.swingbyEvent = sbEvent
        pointerPressEvent(event)
    }

    private func callPointerReleaseEvent(_ sbEvent: UnsafeMutablePointer<sb_event_t>?) {
        let sbButton = sb_event_pointer_button(sbEvent)
        let button: PointerButton = switch sbButton {
            case SB_POINTER_BUTTON_NONE: .none
            case SB_POINTER_BUTTON_LEFT: .left
            case SB_POINTER_BUTTON_RIGHT: .right
            case SB_POINTER_BUTTON_MIDDLE: .middle
            default: .none
        }

        let sbPos = sb_event_pointer_position(sbEvent)
        let x = sb_point_x(sbPos)
        let y = sb_point_y(sbPos)

        let event = PointerEvent(type: .pointerRelease)
        event.button = button
        event.position.x = x
        event.position.y = y
        event.swingbyEvent = sbEvent
        pointerReleaseEvent(event)
    }

    private func callPointerClickEvent(_ sbEvent: UnsafeMutablePointer<sb_event_t>?) {
        let sbButton = sb_event_pointer_button(sbEvent)
        let button: PointerButton = switch sbButton {
            case SB_POINTER_BUTTON_NONE: .none
            case SB_POINTER_BUTTON_LEFT: .left
            case SB_POINTER_BUTTON_RIGHT: .right
            case SB_POINTER_BUTTON_MIDDLE: .middle
            default: .none
        }

        let sbPos = sb_event_pointer_position(sbEvent)
        let x = sb_point_x(sbPos)
        let y = sb_point_y(sbPos)

        let event = PointerEvent(type: .pointerClick)
        event.button = button
        event.position.x = x
        event.position.y = y
        event.swingbyEvent = sbEvent
        pointerClickEvent(event)
    }

    private func callResizeEvent(_ sbEvent: UnsafeMutablePointer<sb_event_t>?) {
        // TODO: Real values.
        let sbOld = sb_event_resize_old_size(sbEvent)!
        let sbSize = sb_event_resize_size(sbEvent)!
        let event = ResizeEvent(
            oldSize: Size(width: sbOld.pointee.width, height: sbOld.pointee.height),
            size: Size(width: sbSize.pointee.width, height: sbSize.pointee.height)
        )
        resizeEvent(event)
    }

    private func callPaintEvent(_ sbEvent: UnsafeMutablePointer<sb_event_t>?) {
        let event = Event(of: .paint)
        paintEvent(event)
    }

    open func pointerEnterEvent(_ event: PointerEvent) {
        ToplevelStorage._uiSurface = self._surface
        _pointerEnterHandler?(event)
        ToplevelStorage._uiSurface = nil
    }

    open func pointerLeaveEvent(_ event: PointerEvent) {
        ToplevelStorage._uiSurface = self._surface
        _pointerLeaveHandler?(event)
        ToplevelStorage._uiSurface = nil
    }

    open func pointerMoveEvent(_ event: PointerEvent) {
        ToplevelStorage._uiSurface = self._surface
        _pointerMoveHandler?(event)
        ToplevelStorage._uiSurface = nil
    }

    open func pointerPressEvent(_ event: PointerEvent) {
        ToplevelStorage._uiSurface = self._surface
        _pointerPressHandler?(event)
        ToplevelStorage._uiSurface = nil
    }

    open func pointerReleaseEvent(_ event: PointerEvent) {
    }

    open func pointerClickEvent(_ event: PointerEvent) {
        ToplevelStorage._uiSurface = self._surface
        _pointerClickHandler?(event)
        onPointerClick?.invoke(event)
        ToplevelStorage._uiSurface = nil
    }

    open func resizeEvent(_ event: ResizeEvent) {
        _resizeHandler?(event)
        self.onResize?.invoke(event)
    }

    open func paintEvent(_ event: Event) {
        _paintHandler?(event)
    }
}
