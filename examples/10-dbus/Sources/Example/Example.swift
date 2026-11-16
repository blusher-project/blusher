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

        let window = BWindow()
        window.size = SizeI(width: 500, height: 400)

        window.show()

        let _ = app.exec()
    }
}
