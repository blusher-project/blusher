public struct Font {
    public enum Weight {
        case thin       // 100
        case extraLight // 200
        case light      // 300
        case regular    // 400
        case medium     // 500
        case semiBold   // 600
        case bold       // 700
        case extraBold  // 800
        case black      // 900
    }

    public var family: String
    public var path: String
    public var ttcIndex: Int
    public var size: Float

    internal init() {
        self.family = ""
        self.path = ""
        self.ttcIndex = 0
        self.size = 1.0
    }
}
