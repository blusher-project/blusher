@_implementationOnly import Swingby

public enum EventType {
    case nextTick
    case pointerEnter
    case pointerLeave
    case pointerMove
    case pointerPress
    case pointerRelease
    case pointerClick
    case paint
    case resize
    case preferredScale
    case timeout
}

typealias EventListener = @convention(c) (
    UnsafeMutablePointer<sb_event_t>?,
    UnsafeMutableRawPointer?
) -> Void

public class Event {
    public var type: EventType
    public var propagation: Bool {
        get {
            if swingbyEvent != nil {
                return sb_event_propagation(swingbyEvent)
            }

            return true
        }
        set {
            if swingbyEvent != nil {
                sb_event_set_propagation(swingbyEvent, newValue)
            }
        }
    }

    internal var swingbyEvent: UnsafeMutablePointer<sb_event_t>? = nil

    public init(of type: EventType) {
        self.type = type
    }
}

public struct EventHandler<T> {
    public final class Handler {
        let closure: (T) -> Void

        public init(_ closure: @escaping (T) -> Void) {
            self.closure = closure
        }
    }

    internal var handlers: [Handler] = []

    public func invoke(_ event: T) {
        self.handlers.forEach {
            $0.closure(event)
        }
    }
}

public func += <T>(_ lhs: inout EventHandler<T>?, _ rhs: EventHandler<T>.Handler) {
    if lhs == nil {
        lhs = EventHandler()
    }
    lhs!.handlers.append(rhs)
}

public func += <T>(_ lhs: inout EventHandler<T>?, _ rhs: @escaping (T) -> Void) {
    if lhs == nil {
        lhs = EventHandler()
    }
    lhs!.handlers.append(EventHandler<T>.Handler(rhs))
}

public func -= <T>(_ lhs: inout EventHandler<T>?, _ rhs: EventHandler<T>.Handler) {
    lhs?.handlers.removeAll { $0 === rhs }
    if lhs?.handlers.count == 0 {
        lhs = nil
    }
}

public func -= <T>(_ lhs: inout EventHandler<T>?, _ rhs: @escaping (T) -> Void) {
    //
}
