import Blusher

let app = BApplication(CommandLine.arguments)

let toplevel = BToplevel()

let view = BView(surface: toplevel.surface, geometry: Rect(x: 0, y: 0, width: 100, height: 100))
view.color = .red

toplevel.show()

app.exec()
