import Blusher
import ImageResources

@main
public struct Program {
    public static func main() {
        let app = BApplication(CommandLine.arguments)

        // Register resources.
        ImageResources.getResources().forEach {
            app.registerResource($0)
        }

        let window = BWindow()
        window.size = SizeI(width: 500, height: 400)
        window.body.layout = CenterLayout()

        let png = ResourceManager.shared.getResource("/org.blusher.Example/swingby.png")
        if png == nil {
            print("Can't find the resource.")
            return
        }

        // let imageFile = FileSystem.File.open("swingby.png", "rb")
        // let data = imageFile.readAll()

        let image = ImageHandle(from: png!.data)

        let view = BView(
            parent: window.body,
            geometry: Rect(x: 0.0, y: 0.0, width: 340.0, height: 150.0)
        )

        view.renderType = .image
        view.image = image

        window.show()

        let _ = app.exec()
    }
}
