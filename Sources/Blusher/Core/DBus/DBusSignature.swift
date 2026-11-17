public struct DBusSignature: ExpressibleByStringLiteral {
    public var rawValue: String

    //==========================================
    // Protocol - ExpresibleByStringLiteral
    //==========================================
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}
