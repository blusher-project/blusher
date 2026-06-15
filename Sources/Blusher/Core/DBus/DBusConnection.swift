internal import CSdBus

public class DBusConnection {
    private var _busPtr: OpaquePointer? = nil
    private var _busType: DBus.BusType

    public var busType: DBus.BusType { _busType }

    public init(type busType: DBus.BusType) {
        _busType = busType

        switch busType {
        case .session:
            sd_bus_default_user(&_busPtr)
        case .system:
            sd_bus_default_system(&_busPtr)
        }
        if _busPtr == nil { print("Failed to connect to the bus.") }
    }

    deinit {
        sd_bus_close(_busPtr)
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
                message.destination,
                message.path,
                message.interface,
                method
            )
            return reply
        } catch {
            print("DBusConnection.callMethod failed!")
            return nil
        }
    }
}
