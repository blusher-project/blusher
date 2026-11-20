internal import CSdBus

typealias SdBusMessageHandler = @convention(c) (
    OpaquePointer?,                     // sd_bus_message
    UnsafeMutableRawPointer?,           // void *user_data
    UnsafeMutablePointer<sd_bus_error>? // sd_bus_error
) -> Int32

public typealias DBusMethodHandler = (String) -> DBusMessage

public class DBusConnection {
    //==============================
    // Private Stored Properties
    //==============================
    private var _busPtr: OpaquePointer? = nil
    private var _busType: DBusBusType
    private var _name: String? = nil
    private var _objects: [DBusObject] = []

    // bl_sd_bus_entry_t
    private var _entries: [OpaquePointer] = []

    //==============================
    // Public Computed Properties
    //==============================
    public var busType: DBusBusType { _busType }

    public var name: String? {
        _name
    }

    public var fd: CInt {
        sd_bus_get_fd(_busPtr)
    }

    //=================
    // Public Inits
    //=================
    public init(type busType: DBusBusType) {
        _busType = busType

        switch busType {
        case .session:
            sd_bus_default_user(&_busPtr)
        case .system:
            sd_bus_default_system(&_busPtr)
        }
        if _busPtr == nil { print("Failed to connect to the bus.") }
    }

    public init(type busType: DBusBusType, address: String) {
        _busType = busType

        if busType == .system {
            Logger.warn("System bus with custom address not supported yet.")
        }

        var err: Int32 = 0
        err = sd_bus_new(&_busPtr)
        if err < 0 {
            Logger.warn("sd_bus_new failed")
        }
        err = sd_bus_set_address(_busPtr, address)
        if err < 0 {
            Logger.warn("sd_bus_set_address failed")
        }
        err = sd_bus_start(_busPtr)
        if err < 0 {
            Logger.warn("sd_bus_start failed. error: \(err)")
        }
    }

    //============
    // Deinit
    //============
    deinit {
        sd_bus_close(_busPtr)
    }

    public func requestName(_ name: String) throws {
        let ret = sd_bus_request_name(_busPtr, name, 0)

        if ret < 0 {
            throw DBusError.unknown
        }

        _name = name
    }

    public func callMethod(
        _ destination: String,
        _ path: String,
        _ interface: String,
        _ member: String,
        _ types: String? = nil
    ) throws -> DBusMessage {
        var err: sd_bus_error = sd_bus_error()
        var reply: OpaquePointer? = nil
        var msg: DBusMessage? = nil
        var retVal: Int32 = 0

        withVaList([]) { vaList in
            retVal = sd_bus_call_methodv(
                _busPtr,
                destination,
                path,
                interface,
                member,
                &err,
                &reply,
                types,
                vaList
            )

            if retVal < 0 {
                // Failed.
                print("DBusConnection.callMethod - err: \(String(cString: err.name))")
            } else {
                // Ok.
                msg = DBusMessage(type: .methodReturn)
                // Fill arguments.
                var arg: DBusArgument? = DBusMessage.read(reply!)
                while arg != nil {
                    msg?.appendArgument(arg!)
                    arg = DBusMessage.read(reply!)
                }
                print(msg!.arguments)
            }
        }

        // Free.
        sd_bus_error_free(&err)

        if retVal < 0 { throw DBusError.unknown }

        return msg!
    }

    public func callMethod(_ message: DBusMessage, _ method: String) -> DBusMessage? {
        do {
            let reply = try self.callMethod(
                message.destination!,
                message.path!,
                message.interface!,
                method
            )
            return reply
        } catch {
            print("DBusConnection.callMethod failed!")
            return nil
        }
    }

    public func addMethod(_ path: String, _ handler: @escaping DBusMethodHandler) {
        let object = DBusObject(path, handler);
        let userData = Unmanaged.passUnretained(object).toOpaque()

        let callback = { msg, userData, error in
            if let userData = userData {
                let instance = Unmanaged<DBusObject>.fromOpaque(userData).takeUnretainedValue()

                let path = instance.path
                let msg = instance.handler(path)
            }
            return 0
        } as SdBusMessageHandler
        object.callback = callback

        let ret = sd_bus_add_object(_busPtr, nil, path, callback, userData)

        _objects.append(object)
    }

    public func registerPath(_ path: some DBusPathProtocol) {
        let callback = { msg, userData, error in
            let message = DBusMessage(cPointer: msg!)
            print(message.path ?? "NoPath")

            if let userData = userData {
                let conn = Unmanaged<DBusConnection>.fromOpaque(userData).takeUnretainedValue()

                conn.replyMethodReturn(message)
            }

            return 1
        } as SdBusMessageHandler
        let userData = Unmanaged.passUnretained(self).toOpaque()
        sd_bus_add_object(_busPtr,
            nil,
            path.value,
            callback,
            userData
        )
    }

    public func replyMethodReturn(_ message: DBusMessage) {
        let _ = withVaList([42]) { va in
            sd_bus_reply_method_returnv(message.cPointer, "i", va)
        }
    }

    public func process() -> DBusMessage {
        var msg: OpaquePointer? = nil
        let err = sd_bus_process(_busPtr, &msg)
        print("err: \(err)")
        var errStr = ""
        if err < 0 {
            if err == -EINVAL {
                errStr = "-EINVAL"
            } else if err == -ECHILD {
                errStr = "-ECHILD"
            } else if err == -ENOTCONN {
                errStr = "-ENOTCONN"
            } else if err == -ECONNRESET {
                errStr = "-ECONNRESET"
            } else if err == -EBUSY {
                errStr = "-EBUSY"
            } else {
                errStr = "..."
            }
            Logger.warn("sd_bus_process failed! \(errStr)")
        }
        if msg == nil {
            return DBusMessage()
        }
        let message = DBusMessage(cPointer: msg!)

        return message
    }

    public func wait() {
        sd_bus_wait(_busPtr, UInt64.max)
    }
}

extension DBusConnection: CustomStringConvertible {
    public var description: String {
        // Get type.
        let t = self.busType == .session ? "Session" : "System"

        return "DBusConnection(\(t))"
    }
}


//====================
// Implementation
//====================
internal class DBusObject {
    public var slot: OpaquePointer?
    public var path: String
    public var handler: DBusMethodHandler
    public var callback: SdBusMessageHandler?
    public var userData: UnsafeMutableRawPointer?

    public init(
        _ path: String,
        _ handler: @escaping DBusMethodHandler
    ) {
        self.slot = nil
        self.path = path
        self.handler = handler
    }
}
