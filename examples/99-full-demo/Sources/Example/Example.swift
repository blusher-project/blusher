import Blusher

import ImageResources

let lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent hendrerit augue erat, a blandit risus accumsan in. Nullam quis tortor a nisi eleifend varius. Etiam eget interdum purus. Proin lobortis aliquam pellentesque. Curabitur vestibulum nisl tellus, vitae pharetra quam tempus nec. Donec imperdiet massa sed libero consequat, ac ullamcorper mi dictum. Cras laoreet tincidunt leo quis fermentum."


@main
public struct Program {
    public static func main() {
        let app = BApplication(CommandLine.arguments)

        // Register resources.
        ImageResources.getResources().forEach {
            app.registerResource($0)
        }

        let window = MainWindow()

        let menuBar = BMenuBar(.commonMenuBarMenu, window: window)


        window.show()

        let _ = app.exec()
    }
}
