@_implementationOnly import Swingby

public enum StrokeSizing {
    case inner
    case center
    case outer
}

public struct Paint {
    public var fillColor: Color = .transparent
    public var strokeColor: Color = .black
    public var strokeWidth: Float = 0.0
    public var strokeSizing: StrokeSizing = .inner

    public init() {
    }
}
