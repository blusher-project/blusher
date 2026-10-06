public struct Color: Equatable, Sendable {
    public var r: Float
    public var g: Float
    public var b: Float
    public var a: Float

    public init(r: Float, g: Float, b: Float, a: Float) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }

    public init(r8: UInt8, g8: UInt8, b8: UInt8, a8: UInt8) {
        self.r = Float(r8) / 255.0
        self.g = Float(g8) / 255.0
        self.b = Float(b8) / 255.0
        self.a = Float(a8) / 255.0
    }

    @available(*, deprecated, message: "Use init(r8:g8:b8:a8) instead.")
    public init(r256: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        self.init(r8: r256, g8: g, b8: b, a8: a)
    }

    public init(hex: UInt32) {
        let r = UInt8((hex >> 16) & 0xFF)
        let g = UInt8((hex >> 8) & 0xFF)
        let b = UInt8(hex & 0xFF)
        let a = UInt8(0xFF)
        self.init(r8: r, g8: g, b8: b, a8: a)
    }

    public init(hex: UInt32, alpha: Double) {
        let r = UInt8((hex >> 16) & 0xFF)
        let g = UInt8((hex >> 8) & 0xFF)
        let b = UInt8(hex & 0xFF)
        self.init(r8: r, g8: g, b8: b, a8: 0)
        self.a = Float(a)
    }

    @available(*, unavailable, message: "Not implemented yet.")
    public init(hex: String) {
        self = .transparent
    }

    @available(*, unavailable, message: "Not implemented yet.")
    public init(hex: String, alpha: Double) {
        self = .transparent
    }
}

public extension Color {
    static var black: Color {
        Color(r: 0.0, g: 0.0, b: 0.0, a: 1.0)
    }

    static var white: Color {
        Color(r: 1.0, g: 1.0, b: 1.0, a: 1.0)
    }

    static var red: Color {
        Color(r: 1.0, g: 0.0, b: 0.0, a: 1.0)
    }

    static var transparent: Color {
        Color(r: 0.0, g: 0.0, b: 0.0, a: 0.0)
    }

    static let blue: Color = Color(r: 0.0, g: 0.0, b: 1.0, a: 1.0)
    // static let silver: Color = Color(hex: "#C0C0C0")
    static let silver: Color = Color(hex: 0xC0C0C0)
    static let gray: Color = Color(hex: 0x808080)
    static let maroon: Color = Color(hex: 0x800000)
    static let yellow: Color = Color(hex: 0xFFFF00)
    static let olive: Color = Color(hex: 0x808000)
    static let lime: Color = Color(hex: 0x00FF00)
    static let green: Color = Color(hex: 0x008000)
    static let aqua: Color = Color(hex: 0x00FFFF)
    static let teal: Color = Color(hex: 0x008080)
    static let navy: Color = Color(hex: 0x000080)
    static let fuchsia: Color = Color(hex: 0xFF00FF)
    static let purple: Color = Color(hex: 0x800080)
}
