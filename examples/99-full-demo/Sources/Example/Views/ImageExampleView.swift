import Blusher

class ImageExampleView: BView {
    public override init() {
        super.init()

        let png = ResourceManager.shared.getResource("/org.blusher.Example/swingby.png")
        if png == nil {
            print("Can't find the resource.")
            return
        }

        // let imageFile = FileSystem.File.open("swingby.png", "rb")
        // let data = imageFile.readAll()

        let view = BView(
            parent: self,
            geometry: Rect(x: 0.0, y: 0.0, width: 340.0, height: 150.0)
        )

        let image = ImageHandle(from: png!.data)

        view.renderType = .image
        view.image = image
    }
}
