public class PropertyAnimation<T>: Animation {
    private var _target: BView
    private var _state: AnimationState
    private var _duration: Int = 0
    private var _delta: Int = 0
    private var _elapsed: Int = 0
    private var _startTime: Int = 0
    private var _easing: CubicBezier = EasingFunction.linear
    private var _repeating: Bool = false

    private var _initial: T
    private var _from: T
    private var _to: T
    private var _last: T
    private var _timerID: Int = -1

    public var target: BView {
        _target
    }

    public var state: AnimationState {
        get { _state }
        set { _state = newValue }
    }
    public var duration: Int {
        get { _duration }
        set { _duration = newValue }
    }
    public var delta: Int {
        get { _delta }
        set { _delta = newValue }
    }
    public var elapsed: Int {
        get { _elapsed }
        set { _elapsed = newValue }
    }
    public var startTime: Int {
        get { _startTime }
        set { _startTime = newValue }
    }
    public var easing: CubicBezier {
        get { _easing }
        set { _easing = newValue }
    }
    public var repeating: Bool {
        get { _repeating }
        set { _repeating = newValue }
    }

    public var initial: T {
        get { _initial }
        set { _initial = newValue }
    }
    public var from: T {
        get { _from }
        set { _from = newValue }
    }
    public var to: T {
        get { _to }
        set { _to = newValue }
    }
    public var last: T {
        get { _last }
        set { _last = newValue }
    }
    public var timerID: Int {
        get { _timerID }
    }

    public init(_ target: BView, _ initial: T) {
        _target = target
        _state = .stopped

        _initial = initial
        _from = initial
        _to = initial
        _last = initial
    }

    public func start() {
        self.stop()

        if _state == .stopped {
            _elapsed = 0
            _delta = _duration
        } else if _state == .reversing {
            if _delta != _duration {
                if !_repeating {
                    _delta = _duration - _delta
                } else {
                    _delta = _duration - _delta + _elapsed
                }
                _repeating = true
            } else {
                _delta = _elapsed
            }
        }
        _startTime = BlusherHelper.timeNowMilliseconds()
        _timerID = BApplication.shared.addTimer(
            to: _target.surface,
            interval: self.interval,
            repeats: true
        )

        _target.surface.onTimeout += self.onTimerStart

        _state = .running
    }

    public func reverse() {
        self.stop()

        if _state == .stopped {
            _elapsed = 0;
            delta = _duration;
        } else if _state == .running {
            if (delta != _duration) {
                if (!_repeating) {
                    delta = _duration - delta
                } else {
                    delta = _duration - delta + _elapsed
                }
                _repeating = true
            } else {
                delta = _elapsed
            }
        }
        _startTime = BlusherHelper.timeNowMilliseconds()
        _timerID = BApplication.shared.addTimer(
            to: _target.surface,
            interval: self.interval,
            repeats: true
        )

        _target.surface.onTimeout += self.onTimerReverse

        _state = .reversing
    }

    public func onTimerStart(_ evt: TimerEvent) {
        if (evt.id != _timerID) {
            return
        }
        let now = BlusherHelper.timeNowMilliseconds()
        self.elapsed = now - self.startTime
        if (self.elapsed > self.delta) {
            self.elapsed = self.delta
        }

        let t = self.easing.evaluate(Float(self.elapsed) / Float(self.delta))

        print("Elapsed: \(self.elapsed), Delta: \(self.delta), t: \(t)")

        self.setProperty(t)

        if (self.elapsed >= self.delta) {
            // _target.surface.removeTimer(_timerID);
            BApplication.shared.removeTimer(for: _timerID)
            _timerID = -1
            _target.surface.onTimeout -= self.onTimerStart

            self.state = .stopped
            self.repeating = false
        }
    }

    public func onTimerReverse(_ evt: TimerEvent) {
        if evt.id != _timerID {
            return
        }
        let now = BlusherHelper.timeNowMilliseconds()

        self.elapsed = now - self.startTime
        if (self.elapsed > self.delta) {
            self.elapsed = self.delta
        }

        let t = self.easing.evaluate(Float(self.elapsed) / Float(self.delta))

        print("Elapsed: \(self.elapsed), Delta: \(self.delta), t: \(t)")

        self.setProperty(t)

        if _elapsed >= _delta {
            // _target.surface.removeTimer(_timerID)
            BApplication.shared.removeTimer(for: _timerID)
            _timerID = -1
            _target.surface.onTimeout -= self.onTimerReverse

            _state = .stopped
            _repeating = false
        }
    }

    internal func setProperty(_ t: Float) {
        //
    }

    internal func setAsFromProperty() {
        //
    }

    internal func setAsToProperty() {
        //
    }

    internal func stop() {
        // Last = Target.Value;
        if _timerID != -1 {
            BApplication.shared.removeTimer(for: _timerID)
            _timerID = -1
            _target.surface.onTimeout -= self.onTimerStart
            _target.surface.onTimeout -= self.onTimerReverse
        }
    }

    public static func lerp(_ a: Float, _ b: Float, _ t: Float) -> Float
    {
        return a + (b - a) * t
    }
}
