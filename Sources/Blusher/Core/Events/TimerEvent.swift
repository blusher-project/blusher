public class TimerEvent: Event {
    public var id: Int = -1
    public var interval: Int
    public var repeats: Bool

    public init(interval: Int, repeats: Bool) {
        self.interval = interval
        self.repeats = repeats

        super.init(of: .timeout)
    }
}
