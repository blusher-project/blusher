internal import CSdBus

public enum DBusBusType {
    case session
    case system
}

public enum DBusBasicType {
    case byte
    case boolean
    case int16
    case int32
    case int64
    case uint16
    case uint32
    case uint64
    case double
    case fd
    case string
    case objectPath
    case signature
}

public enum DBusContainerType {
    case array
    case `struct`
    case variant
    case dictEntry
}

public struct DBusSignatureOld: Sendable {
    public static let invalid = DBusSignatureOld(rawValue: "\0")
    public static let bytes = DBusSignatureOld(rawValue: "y")   // TODO: bytes -> byte
    public static let boolean = DBusSignatureOld(rawValue: "b")
    public static let int16 = DBusSignatureOld(rawValue: "n")
    public static let uint16 = DBusSignatureOld(rawValue: "q")
    public static let int32 = DBusSignatureOld(rawValue: "i")
    public static let uint32 = DBusSignatureOld(rawValue: "u")
    public static let int64 = DBusSignatureOld(rawValue: "x")
    public static let uint64 = DBusSignatureOld(rawValue: "t")
    public static let double = DBusSignatureOld(rawValue: "d")
    public static let fd = DBusSignatureOld(rawValue: "h")
    public static let string = DBusSignatureOld(rawValue: "s")
    public static let objectPath = DBusSignatureOld(rawValue: "o")
    public static let signature = DBusSignatureOld(rawValue: "g")
    // TODO: Add containers.

    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public enum DBusError: Error {
    case unknown
}
