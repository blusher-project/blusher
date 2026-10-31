@_implementationOnly import Swingby

public enum PopupGrab {
    case button
    case key
}

open class BPopup: BDesktopSurface {
    private var _grabbable: Bool = false
    private var _position: Point = Point(x: 0.0, y: 0.0)
    private weak var _parent: BDesktopSurface? = nil

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

            var newPos = newValue
            if let desktopSurface = _parent {
                newPos.x -= Double(desktopSurface.wmGeometry.x)
                newPos.y -= Double(desktopSurface.wmGeometry.y)
            }
            var sbPoint = pointToSbPoint(newPos)
            sb_desktop_surface_popup_set_position(super.cPointer, &sbPoint)
        }
    }

    public init(at position: Point, _ parent: BDesktopSurface) {
        _parent = parent
        super.init(role: .popup)

        self.position = position

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
