internal import CSdBus

public protocol DBusPathProtocol {
    var count: Int { get }
}

public struct DBusEntryPath<each I: DBusInterfaceProtocol>: DBusPathProtocol {
    public var value: String
    public var interfaces: (repeat each I)

    public var count: Int {
        var count = 0
        print(self.interfaces)
        for _ in repeat (each self.interfaces) {
            count += 1
        }
        return count
    }

    public var introspection: String {
        let builder = DBusIntrospection.Builder()
        builder.nodeBegin()

        for interface in repeat (each self.interfaces) {
            builder.interfaceBegin(name: interface.name)
            // let entries = interface.entries
        }

        builder.nodeEnd()

        return builder.value
    }

    public init(
        _ path: String,
        @DBusInterfaceBuilder _ ifaces: () -> (repeat each I)
    ) {
        self.value = path
        self.interfaces = ifaces()
    }
}

public protocol DBusInterfaceProtocol {
    var name: String { get }
}

public struct DBusEntryInterface<each E: DBusEntry>: DBusInterfaceProtocol {
    public var name: String
    public var entries: (repeat each E)

    public func getName() -> String {
        return name
    }

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
    public struct Argument {
        public enum Direction {
            case `in`
            case out
        }

        public init(_ name: String, _ type: DBusType) {
            //
        }

        public static func argument(
            name: String,
            type: DBusType
        ) -> Argument {
            return Argument(name, type)
        }
    }

    public var name: String
    public var inputArguments: [Argument] = []
    public var outputArguments: [Argument] = []

    public init(name: String, in: DBusSignature, out: DBusSignature) {
        self.name = name
    }

    public init(name: String, in: [Argument], out: [Argument]) {
        self.name = name
        self.inputArguments = `in`
        self.outputArguments = out
    }

    public init(name: String) {
        self.name = name
    }

    public func `in`(_ args: [Argument]) -> DBusMethod {
        var new = self
        new.inputArguments = args

        return new
    }

    public func out(_ args: [Argument]) -> DBusMethod {
        var new = self
        new.outputArguments = args

        return new
    }
}

// public struct DBusStart: DBusEntry {
//     //
// }

public struct DBusEmptyEntry: DBusEntry {
    // public var entry: Never {}
}


// TODO: REMOVE. This is for an editor error check. Must be removed.
internal enum GrammarTest {
    static func test() {
        let path: some DBusPathProtocol = DBusEntryPath("/org/example/Test") {
            DBusEntryInterface(name: "org.example.Test") {
                DBusMethod(name: "SayHello", in: "", out: "s")
                DBusMethod(name: "SayGoodbye", in: "", out: "s")
                DBusMethod(
                    name: "WithArgs",
                    in: [
                        .argument(name: "name", type: .string),
                    ],
                    out: [
                        .argument(name: "greeting", type: .string),
                        .argument(name: "count", type: .int32),
                    ]
                )
            }
        }
    }
}
