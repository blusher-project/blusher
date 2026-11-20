import Blusher

@main
public struct Program {
    public static func onMessage(_ message: DBusMessage) {
        print(message.destination)
        print(message.path)
        print(message.interface)
    }

    public static func main() {
        let app = BApplication(CommandLine.arguments)

        let dbusConnection = DBusConnection(type: .session)
        do {
            try dbusConnection.requestName("org.blusher.Example")
        } catch {
            print("Failed to get the requested name.")
        }

        // dbusConnection.addMethod("")

        let rootPath = DBusPath("/") {
            DBusEntryInterface(name: "org.freedesktop.DBus.Introspectable") {
                DBusMethod(
                    name: "Introspect",
                    in: [],
                    out: []
                )
            }
        }
        dbusConnection.registerPath(rootPath)


        let path = DBusPath("/org/blusher/Example") {
            DBusEntryInterface(name: "org.blusher.Example") {
                DBusMethod(
                    name: "SayHello",
                    in: [ .argument(name: "name", type: .string) ],
                    out: [ .argument(name: "greeting", type: .string )]
                )
                DBusMethod(
                    name: "Dummy",
                    in: [],
                    out: []
                )
            }
            // DBusEntryInterface(name: "org.example.Test.New") {
            // }
        }
        dbusConnection.registerPath(path)

        print(path.count)
        print(path.introspection)
        print(dbusConnection.fd)

        let _ = dbusConnection.process()
        while true {
            dbusConnection.wait()
            let message = dbusConnection.process()
            print(message.path ?? "No path")
            print(message.type)
        }


        let window = BWindow()
        window.size = SizeI(width: 500, height: 400)

        window.show()

        let _ = app.exec()
    }
}
