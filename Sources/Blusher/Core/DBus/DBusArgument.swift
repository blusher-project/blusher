public class DBusArgument {
    //=================
    // Old API
    //=================
    public var signature: DBusSignatureOld
    public var value: DBusValue

    public init(_ signature: DBusSignatureOld, _ value: DBusValue) {
        if Self.validate(signature, value) == false {
            self.signature = .invalid
            self.value = false

            return
        }
        self.signature = signature
        self.value = value
    }

    private static func validate(_ signature: DBusSignatureOld, _ value: Any) -> Bool {
        switch signature.rawValue {
        case DBusSignatureOld.bytes.rawValue: value as? String != nil
        case DBusSignatureOld.string.rawValue: value as? String != nil
        // TODO: All cases.
        default: false
        }
    }

    //================
    // New API
    //================
    public init(_ value: DBusValue) {
        // Old compatibility
        self.signature = .string

        self.value = value
    }
}

public protocol DBusValue {
    var dbusType: DBusType { get }
}

public protocol DBusBasicValue: DBusValue, Hashable {}

extension UInt8: DBusBasicValue {
    public var dbusType: DBusType { .byte }
}
extension Bool: DBusBasicValue {
    public var dbusType: DBusType { .boolean }
}
extension Int16: DBusBasicValue {
    public var dbusType: DBusType { .int16 }
}
extension Int32: DBusBasicValue {
    public var dbusType: DBusType { .int32 }
}
extension Int64: DBusBasicValue {
    public var dbusType: DBusType { .int64 }
}
extension UInt16: DBusBasicValue {
    public var dbusType: DBusType { .uint16 }
}
extension UInt32: DBusBasicValue {
    public var dbusType: DBusType { .uint32 }
}
extension UInt64: DBusBasicValue {
    public var dbusType: DBusType { .uint64 }
}
extension Double: DBusBasicValue {
    public var dbusType: DBusType { .double }
}
// extension Fd
extension String: DBusBasicValue {
    public var dbusType: DBusType { .string }
}
// extension ObjectPath
// extension Signature
extension Array: DBusValue where Element: DBusValue {
    public var dbusType: DBusType { .array }
}
extension Dictionary: DBusValue where Key: DBusBasicValue, Value: DBusValue {
    public var dbusType: DBusType { .dictEntry }
}

public struct DBusStruct<each T: DBusValue>: DBusValue {
    public var dbusType: DBusType { .struct }

    public var values: (repeat each T)

    public init(_ values: (repeat each T)) {
        self.values = values
    }
}

extension DBusArgument: CustomStringConvertible {
    public var description: String {
        if self.signature.rawValue == DBusSignatureOld.invalid.rawValue {
            return "DBusArgument(invalid)"
        } else if self.signature.rawValue == DBusSignatureOld.string.rawValue {
            return "DBusArgument(\"\(self.value as! String)\")"
        }
        return "DBusArgument(\(self.signature.rawValue))"
    }
}
