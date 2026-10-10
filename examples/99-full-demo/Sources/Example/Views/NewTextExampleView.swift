import Blusher

class NewTextExampleView: BView {
    private var _textLayout: TextLayout2

    override init() {
        let font = FontLibrary.shared.findFont(family: "serif", size: 12.5)!
        _textLayout = TextLayout2()
        _textLayout.font = font
        _textLayout.text = lorem

        super.init()

        self.size = Size(width: 300.0, height: 300.0)
        self.renderType = .canvas
    }

    override func paintEvent(_ event: Event) {
        // Background.
        let bgRect = Rect(x: 0.0, y: 0.0, width: self.size.width - 100.0, height: self.size.height)
        var bgPaint = Paint()
        bgPaint.fillColor = Color(r: 0.8, g: 0.8, b: 0.8, a: 1.0)
        self.canvas?.drawRect(bgRect, bgPaint)

        // Text layout.
        _textLayout.width = Float(self.size.width) - Float(100.0)

        self.canvas?.drawTextLayout(_textLayout, Point(x: 0.0, y: 0.0))

        super.paintEvent(event)
    }
}
