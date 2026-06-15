public class DBusArgument {
    public var signature: DBusSignature
    public var value: Any

    public init(_ signature: DBusSignature, _ value: Any) {
        if Self.validate(signature, value) == false {
            self.signature = .invalid
            self.value = false

            return
        }
        self.signature = signature
        self.value = value
    }

    private static func validate(_ signature: DBusSignature, _ value: Any) -> Bool {
        switch signature.rawValue {
        case DBusSignature.bytes.rawValue: value as? String != nil
        case DBusSignature.string.rawValue: value as? String != nil
        // TODO: All cases.
        default: false
        }
    }
}

extension DBusArgument: CustomStringConvertible {
    public var description: String {
        if self.signature.rawValue == DBusSignature.invalid.rawValue {
            return "DBusArgument(invalid)"
        } else if self.signature.rawValue == DBusSignature.string.rawValue {
            return "DBusArgument(\"\(self.value as! String)\")"
        }
        return "DBusArgument(\(self.signature.rawValue))"
    }
}
