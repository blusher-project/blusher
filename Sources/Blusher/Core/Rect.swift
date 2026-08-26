public struct Rect: Equatable {
    public var position: Point = Point(x: 0.0, y: 0.0)
    public var size: Size = Size(width: 0.0, height: 0.0)

    public init(x: Double, y: Double, width: Double, height: Double) {
        position.x = x
        position.y = y
        size.width = width
        size.height = height
    }

    public var x: Double {
        get { position.x }
        // set { position.x = newValue }
    }

    public var y: Double {
        get { position.y }
        // set { position.y = newValue }
    }

    public var width: Double {
        get { size.width }
        // set { size.width = newValue }
    }

    public var height: Double {
        get { size.height }
        // set { size.height = newValue }
    }
}

extension Rect: CustomStringConvertible {
    public var description: String {
        return "Blusher.Rect(\(x), \(y) \(width)x\(height))"
    }
}

public struct RectI: Equatable {
    public var position: PointI = PointI(x: 0, y: 0)
    public var size: SizeI = SizeI(width: 0, height: 0)

    public init(x: Int, y: Int, width: Int, height: Int) {
        position.x = x
        position.y = y
        size.width = width
        size.height = height
    }
}

extension RectI: CustomStringConvertible {
    public var description: String {
        return "Blusher.RectI(\(position.x), \(position.y) \(size.width)x\(size.height))"
    }
}
