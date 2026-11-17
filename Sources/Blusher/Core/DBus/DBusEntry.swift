internal import CSdBus

public protocol DBusPathProtocol {}

public struct DBusEntryPath<each I: DBusInterfaceProtocol>: DBusPathProtocol {
    public var value: String
    public var interfaces: (repeat each I)

    public init(
        _ path: String,
        @DBusInterfaceBuilder _ ifaces: () -> (repeat each I)
    ) {
        self.value = path
        self.interfaces = ifaces()
    }
}

public protocol DBusInterfaceProtocol {}

public struct DBusEntryInterface<each E: DBusEntry>: DBusInterfaceProtocol {
    public var name: String
    public var entries: (repeat each E)

    public init(
        name: String,
        @DBusEntryBuilder _ entries: () -> (repeat each E)
    ) {
        self.name = name
        self.entries = entries()
    }
}

@resultBuilder
public struct DBusEntryBuilder {
    public static func buildBlock<each Entry: DBusEntry>(
        _ entry: repeat each Entry
    ) -> (repeat each Entry) {
        (repeat each entry)
    }
}

@resultBuilder
public struct DBusInterfaceBuilder {
    public static func buildBlock<each Interface: DBusInterfaceProtocol>(
        _ iface: repeat each Interface
    ) -> (repeat each Interface) {
        (repeat each iface)
    }
}

public protocol DBusEntry {}

public struct DBusMethod: DBusEntry {
    public var name: String

    public init(name: String, in: DBusSignature, out: DBusSignature) {
        self.name = name
    }
}

// public struct DBusStart: DBusEntry {
//     //
// }

public struct DBusEmptyEntry: DBusEntry {
    // public var entry: Never {}
}


// TODO: REMOVE. This is for an editor error check. Must be removed.
internal enum GrammerTest {
    static func test() {
        let path: some DBusPathProtocol = DBusEntryPath("/org/example/Test") {
            DBusEntryInterface(name: "org.example.Test") {
                DBusMethod(name: "SayHello", in: "", out: "s")
                DBusMethod(name: "SayGoodbye", in: "", out: "s")
            }
        }
    }
}
