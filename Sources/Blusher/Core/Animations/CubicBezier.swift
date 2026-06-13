public struct CubicBezier: Sendable {
    private let _x1, _x2, _y1, _y2: Float

    public init(_ x1: Float, _ y1: Float, _ x2: Float, _ y2: Float) {
        _x1 = x1
        _y1 = y1
        _x2 = x2
        _y2 = y2
    }

    private static func bezier(_ t: Float, _ p1: Float, _ p2: Float) -> Float
    {
        let c = 3 * p1;
        let b = 3 * (p2 - p1) - c;
        let a = 1 - c - b;
        return ((a * t + b) * t + c) * t;
    }

    private static func solveBezier(
        _ t: Float,
        _ p1: Float,
        _ p2: Float,
        _ iterations: Int = 5
    ) -> Float {
        var x = t
        for _ in 0..<iterations {
            let f = Self.bezier(x, p1, p2) - t
            let df = Self.bezierDerivative(x, p1, p2)
            if abs(df) < 1e-6 {
                break
            }
            x -= f / df
            x = Self.clamp(x, 0.0, 1.0)
        }
        return x
    }

    private static func bezierDerivative(_ t: Float, _ p1: Float, _ p2: Float) -> Float
    {
        let c = 3 * p1
        let b = 3 * (p2 - p1) - c
        let a = 1 - c - b
        return (3 * a * t + 2 * b) * t + c
    }

    private static func clamp(_ x: Float, _ min: Float, _ max: Float) -> Float {
        return Swift.min(Swift.max(x, min), max)
    }

    public func evaluate(_ t: Float) -> Float {
        // Solve x for t using Newton-Raphson method (invert Bezier x(t))
        let x = Self.solveBezier(t, _x1, _x2)
        return Self.bezier(x, _y1, _y2)  // Get y at x
    }
}
