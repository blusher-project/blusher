public enum AnimationState {
    case stopped
    case running
    case reversing
}

public protocol Animation {
    var state: AnimationState { get }
    var duration: Int { get set }
    var delta: Int { get set }
    var elapsed: Int { get set }
    var startTime: Int { get set }
    var interval: Int { get set }
    var easing: CubicBezier { get set }
    var repeating: Bool { get set }

    // init(_ target: BView)
}

public extension Animation {
    var duration: Int { 0 }
    var delta: Int { 0 }
    var elapsed: Int { 0 }
    var startTime: Int { 0 }
    var interval: Int {
        get { 16 }
        set { }
    }
    var easing: CubicBezier { EasingFunction.linear }
    var repeating: Bool { false }
}
