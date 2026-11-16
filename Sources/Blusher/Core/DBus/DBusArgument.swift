public class DBusArgument {
    //=================
    // Old API
    //=================
    public var signature: DBusSignatureOld
    public var value: Any

    public init(_ signature: DBusSignatureOld, _ value: Any) {
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
    public init(_ value: String) {
        // Old compatibility
        self.signature = .string
        self.value = value
    }
}

public protocol DBusValue {}
public protocol DBusBasicValue: DBusValue, Hashable {}

extension UInt8: DBusBasicValue {}
extension Bool: DBusBasicValue {}
extension Int16: DBusBasicValue {}
extension Int32: DBusBasicValue {}
extension Int64: DBusBasicValue {}
extension UInt16: DBusBasicValue {}
extension UInt32: DBusBasicValue {}
extension UInt64: DBusBasicValue {}
extension Double: DBusBasicValue {}
// extension Fd
extension String: DBusBasicValue {}
// extension ObjectPath
// extension Signature
extension Array<DBusValue>: DBusContainerValue {}
// extension Dictionary<DBusBasicValue, DBusValue>: DBusValue {}

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
