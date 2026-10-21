open class BLabel: BView {
    private var _text: String = ""
    private var _textLayout: TextLayout

    public var text: String {
        get { _text }
        set {
            _text = newValue
            _textLayout.text = newValue
        }
    }

    public override var preferredSize: Size? {
        _textLayout.lines[0].boundingRect.size
    }

    public init(_ text: String, parent: BView) {
        _text = text
        _textLayout = TextLayout()
        _textLayout.text = _text
        _textLayout.update()

        super.init(parent: parent)

        self.renderType = .canvas
        self.geometry = Rect(x: 0.0, y: 0.0, width: 100.0, height: 30.0)
    }

    open override func paintEvent(_ event: Event) {
        var paint = Paint()
        paint.fillColor = .red
        paint.fillColor.a = 0.5
        let debugBg = Rect(
            x: 0.0,
            y: 0.0,
            width: _textLayout.lines[0].boundingRect.width,
            height: _textLayout.lines[0].boundingRect.height
        )
        self.canvas?.drawRect(debugBg, paint)
        self.canvas?.drawTextLayout(_textLayout, Point(x: 0.0, y: 0.0))

        super.paintEvent(event)
    }
}
