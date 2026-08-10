public struct CubicBezier: Sendable {
    private let _x1, _x2, _y1, _y2: Double

    public init(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double) {
        _x1 = x1
        _y1 = y1
        _x2 = x2
        _y2 = y2
    }

    private static func bezier(_ t: Double, _ p1: Double, _ p2: Double) -> Double
    {
        let c = 3 * p1;
        let b = 3 * (p2 - p1) - c;
        let a = 1 - c - b;
        return ((a * t + b) * t + c) * t;
    }

    private static func solveBezier(
        _ t: Double,
        _ p1: Double,
        _ p2: Double,
        _ iterations: Int = 5
    ) -> Double {
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

    private static func bezierDerivative(_ t: Double, _ p1: Double, _ p2: Double) -> Double
    {
        let c = 3 * p1
        let b = 3 * (p2 - p1) - c
        let a = 1 - c - b
        return (3 * a * t + 2 * b) * t + c
    }

    private static func clamp(_ x: Double, _ min: Double, _ max: Double) -> Double {
        return Swift.min(Swift.max(x, min), max)
    }

    public func evaluate(_ t: Double) -> Double {
        // Solve x for t using Newton-Raphson method (invert Bezier x(t))
        let x = Self.solveBezier(t, _x1, _x2)
        return Self.bezier(x, _y1, _y2)  // Get y at x
    }
}
