public struct Size: Equatable {
    public var width: Double
    public var height: Double

    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
}

public struct SizeI: Equatable {
    public var width: Int
    public var height: Int

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    /// Convert to `Blusher.Size`.
    public func toSize() -> Size {
        return Size(width: Double(self.width), height: Double(self.height))
    }
}
