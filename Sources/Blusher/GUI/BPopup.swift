@_implementationOnly import Swingby

public enum PopupGrab {
    case button
    case key
}

open class BPopup: BDesktopSurface {
    private var _grabbable: Bool = false
    private var _position: Point = Point(x: 0.0, y: 0.0)

    public var grabbable: Bool {
        get { _grabbable }
        set {
            _grabbable = newValue
            sb_desktop_surface_popup_set_grabbable(super.cPointer, newValue)
        }
    }

    public var position: Point {
        get { _position }
        set {
            _position = newValue

            var sbPoint = pointToSbPoint(newValue)
            sb_desktop_surface_popup_set_position(super.cPointer, &sbPoint)
        }
    }

    public init(at position: Point, _ parent: BDesktopSurface) {
        super.init(role: .popup)
        var sbPoint = sb_point_t(x: Float(position.x), y: Float(position.y))
        sb_desktop_surface_popup_set_position(super.cPointer, &sbPoint)

        sb_desktop_surface_set_parent(super.cPointer, parent.cPointer)
    }

    public func grab(for grab: PopupGrab) {
        if grab == .button {
            sb_desktop_surface_popup_grab_for_button(super.cPointer)
        } else {
            // TODO!
        }
    }
}
