public class ScaleEvent: Event {
    public var scale: Float

    public init(scale: Float) {
        self.scale = scale

        super.init(of: .preferredScale)
    }
}
