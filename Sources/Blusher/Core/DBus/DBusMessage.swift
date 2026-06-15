internal import CSdBus

public enum DBusMessageType {
    case methodCall
    case methodReturn
    case error
    case signal
}

public class DBusMessage {
    private var _msgPtr: OpaquePointer? = nil
    private var _type: DBusMessageType
    private var _destination: String? = nil
    private var _path: String? = nil
    private var _interface: String? = nil
    private var _arguments: [DBusArgument] = []

    public var destination: String {
        get { _destination ?? "" }
        set { _destination = newValue }
    }

    public var path: String {
        get { _path ?? "" }
        set { _path = newValue }
    }

    public var interface: String {
        get { _interface ?? "" }
        set { _interface = newValue }
    }

    public var arguments: [DBusArgument] {
        _arguments
    }

    //===============
    // Init/Deinit
    //===============

    internal init() {
        _type = .error
    }

    public init(type: DBusMessageType) {
        _type = type
    }

    internal static func makeFromReply(_ ptr: OpaquePointer) -> DBusMessage {
        let msg = DBusMessage()
        msg._msgPtr = ptr
        msg._type = .methodReturn

        return msg
    }

    internal static func makeMethodCall(
        _ destination: String,
        _ path: String,
        _ interface: String
    ) -> DBusMessage {
        let msg = DBusMessage()
        msg._type = .methodCall
        msg._destination = destination
        msg._path = path
        msg._interface = interface

        return msg
    }

    //===========================
    // Private Static Methods
    //===========================

    private static func getType(_ cChar: CChar) -> DBusSignature {
        if cChar == CChar(bitPattern: UInt8(ascii: "s")) {
            return .string
        } else {
            return .invalid
        }
    }

    private static func getString(_ ptr: UnsafeMutableRawPointer) -> String {
        String(cString: ptr.assumingMemoryBound(to: CChar.self))
    }

    //==========================
    // Public Static Methods
    //==========================

    public static func read(_ msgPtr: OpaquePointer) -> DBusArgument? {
        var typeOut: CChar = 0
        var val: UnsafeMutableRawPointer? = nil
        var err: Int32 = 0
        err = sd_bus_message_peek_type(msgPtr, &typeOut, nil)

        err = sd_bus_message_read_basic(msgPtr, typeOut, &val)
        if err < 0 {
            // Failed.
            print("Failed")
            return nil
        } else if err == 0 {
            // End.
            print("End")
            return nil
        } else {
            // Ok.
            print("Ok")
            if Self.getType(typeOut).rawValue == DBusSignature.string.rawValue {
                return DBusArgument(.string, Self.getString(val!))
            }
        }

        return nil
    }

    //=================
    // Public Methods
    //=================

    public func appendArgument(_ arg: DBusArgument) {
        _arguments.append(arg)
    }
}
