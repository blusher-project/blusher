internal import CSdBus

public enum DBus {
    public enum BusType {
        case session
        case system
    }

    public enum `Type` {
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
    }
}

public struct DBusSignature: Sendable {
    public static let invalid = DBusSignature(rawValue: "\0")
    public static let bytes = DBusSignature(rawValue: "y")
    public static let boolean = DBusSignature(rawValue: "b")
    public static let int16 = DBusSignature(rawValue: "n")
    public static let uint16 = DBusSignature(rawValue: "q")
    public static let int32 = DBusSignature(rawValue: "i")
    public static let uint32 = DBusSignature(rawValue: "u")
    public static let int64 = DBusSignature(rawValue: "x")
    public static let uint64 = DBusSignature(rawValue: "t")
    public static let double = DBusSignature(rawValue: "d")
    public static let fd = DBusSignature(rawValue: "h")
    public static let string = DBusSignature(rawValue: "s")
    public static let objectPath = DBusSignature(rawValue: "o")
    public static let signature = DBusSignature(rawValue: "g")
    // TODO: Add containers.

    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public enum DBusError: Error {
    case unknown
}

public typealias DBusBusType = DBus.BusType
public typealias DBusType = DBus.`Type`
