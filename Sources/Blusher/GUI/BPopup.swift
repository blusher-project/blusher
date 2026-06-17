@_implementationOnly import Swingby

public enum PopupGrab {
    case button
    case key
}

open class BPopup: BSurface {
    private var _grabbable: Bool = false

    public var grabbable: Bool {
        get { _grabbable }
        set {
            _grabbable = newValue
            sb_desktop_surface_popup_set_grabbable(super.sbDesktopSurface, newValue)
        }
    }

    public init(at position: Point, _ parent: BSurface) {
        super.init(role: .popup, parent)
        var sbPoint = sb_point_t(x: position.x, y: position.y)
        sb_desktop_surface_popup_set_position(super.sbDesktopSurface, &sbPoint)
    }

    public func grab(for grab: PopupGrab) {
        if grab == .button {
            sb_desktop_surface_popup_grab_for_button(super.sbDesktopSurface)
        } else {
            // TODO!
        }
    }
}
