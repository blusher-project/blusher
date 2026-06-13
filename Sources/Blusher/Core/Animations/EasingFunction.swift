public enum EasingFunction {
    public static let ease = CubicBezier(0.25, 0.1, 0.25, 1.0)
    public static let easeIn = CubicBezier(0.42, 0.0, 1.0, 1.0)
    public static let easeOut = CubicBezier(0.0, 0.0, 0.58, 1.0)
    public static let easeInOut = CubicBezier(0.42, 0.0, 0.58, 1.0)
    public static let linear = CubicBezier(0, 0, 1, 1)
}
