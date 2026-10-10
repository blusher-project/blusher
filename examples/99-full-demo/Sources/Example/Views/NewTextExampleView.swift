import Blusher

class NewTextExampleView: BView {
    override init() {
        super.init()

        self.renderType = .canvas
    }

    override func paintEvent(_ event: Event) {
        let textLayout = TextLayout2()

        textLayout.text = lorem

        self.canvas?.drawTextLayout(textLayout, Point(x: 0.0, y: 0.0))

        super.paintEvent(event)
    }
}
