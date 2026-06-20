import Blusher

let lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent hendrerit augue erat, a blandit risus accumsan in. Nullam quis tortor a nisi eleifend varius. Etiam eget interdum purus. Proin lobortis aliquam pellentesque. Curabitur vestibulum nisl tellus, vitae pharetra quam tempus nec. Donec imperdiet massa sed libero consequat, ac ullamcorper mi dictum. Cras laoreet tincidunt leo quis fermentum."


@main
public struct Program {
    public static func main() {
        let app = BApplication(CommandLine.arguments)

        let window = BWindow()
        window.size = SizeI(width: 500, height: 400)

        // Text area.
        let textArea = BView(
            parent: window.body,
            geometry: Rect(x: 0.0, y: 0.0, width: 340.0, height: 400.0)
        )
        textArea.color = Color(r: 0.8, g: 0.8, b: 0.8, a: 1.0)

        let font = FontLibrary.shared.findFont(family: "serif", size: 12.5)

        let textView = BTextView(lorem, font!, parent: textArea)
        textView.text = lorem

        window.body.onResize += { event in
            let geometry = Rect(
                x: 0.0,
                y: 0.0,
                width: window.body.size.width - 100.0,
                height: window.body.size.height
            )
            textArea.geometry = geometry
            textView.geometry = geometry

            print(textView.textLayout?.width)
        }

        // Button panel.
        let buttonPanel = BView(
            parent: window.body,
            geometry: Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        )
        buttonPanel.layout = VBoxLayout()
        window.body.onResize += { event in
            let geometry = Rect(
                x: textArea.size.width, y: 0.0,
                width: 100.0, height: window.body.size.height
            )
            buttonPanel.geometry = geometry
        }

        // Buttons.
        let loremIpsum = BButton("Lorem Ipsum", parent: buttonPanel)
        loremIpsum.onPointerClick += { evt in
            textView.text = lorem
        }
        let helloWorld = BButton("Hello, world", parent: buttonPanel)
        helloWorld.onPointerClick += { evt in
            textView.text = "Hello, world"
        }

        window.show()

        let _ = app.exec()
    }
}
