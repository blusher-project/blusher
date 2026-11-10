@_implementationOnly import Swingby

public enum PopupGrab {
    case button
    case key
}

open class BPopup: SurfaceRole {
    private var _sbPopup: OpaquePointer
    private var _surface: BSurface
    private var _grabbable: Bool = false
    private var _position: PointI = PointI(x: 0, y: 0)
    private weak var _parent: any SurfaceRole? = nil

    public var grabbable: Bool {
        get { _grabbable }
        set {
            _grabbable = newValue
            sb_popup_set_grabbable(_sbPopup, newValue)
        }
    }

    public var position: PointI {
        get { _position }
        set {
            _position = newValue

            var newPos = newValue
            if let parent = _parent {
                if let parentToplevel = parent as? BToplevel {
                    newPos.x -= parentToplevel.wmGeometry?.x ?? 0
                    newPos.y -= parentToplevel.wmGeometry?.y ?? 0
                }
            }
            let sbPoint = pointIToSbPointI(newPos)
            sb_popup_set_position(_sbPopup, sbPoint)
        }
    }

    public var surface: BSurface {
        _surface
    }

    public var roleName: String {
        "popup"
    }

    public init(at position: PointI, _ parent: SurfaceRole) {
        _sbPopup = sb_popup_new()
        _surface = BSurface(sbSurface: sb_popup_surface(_sbPopup))

        _parent = parent

        self.position = position

        if let parent = parent as? BToplevel {
            let cPtr = UnsafeMutablePointer<sb_surface_role_header_t>(parent.cPointer)
            sb_popup_set_parent(_sbPopup, cPtr)
        } else if let parent = parent as? BPopup {
            sb_popup_set_parent(_sbPopup, UnsafeMutablePointer(parent._sbPopup))
        }

        // sb_popup_set_parent(_sbPopup, parent._sbPopup)
    }

    public func show() {
        sb_popup_show(_sbPopup)
    }

    public func hide() {
        sb_popup_hide(_sbPopup)
    }

    public func grab(for grab: PopupGrab) {
        if grab == .button {
            sb_popup_grab_for_button(_sbPopup)
        } else {
            // TODO!
        }
    }
}
