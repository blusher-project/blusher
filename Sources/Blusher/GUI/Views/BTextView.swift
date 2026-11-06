public class BTextView: BView {
    private var _text: String = ""
    private var _multiline: Bool = true
    private var _cursor: BView!
    private var _textLayout: TextLayout = TextLayout()

    public var isMultiline: Bool {
        get { _multiline }
        set { _multiline = newValue }
    }

    public var text: String {
        get { _text }
        set {
            if newValue != _text {
                _text = newValue
                _textLayout.text = newValue
            }
        }
    }

    public override var geometry: Rect {
        get { super.geometry }
        set {
            super.geometry = newValue
            // _textLayout.width = Float(newValue.width)
        }
    }

    public override var position: Point {
        get { super.position }
        set { super.position = newValue }
    }

    public override var size: Size {
        get { super.size }
        set {
            super.size = newValue
            // _textLayout.width = Float(newValue.width) * Float(super.surface!.scale)
        }
    }

    public init(_ text: String, _ font: Font, parent: BView) {
        super.init(parent: parent, geometry: Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))

        super.renderType = .canvas
        // super.textLayout = TextLayout()
        _textLayout.font = font
        _textLayout.text = text
        _textLayout.width = 100.0
        self.text = text

        _cursor = BView(parent: self, geometry: Rect(x: 0.0, y: 0.0, width: 1.0, height: 6.0))
        _cursor.color = .black
    }

    public override func paintEvent(_ event: Event) {
        _textLayout.width = Float(self.size.width)
        self.canvas?.drawTextLayout(self._textLayout, Point(x: 0.0, y: 0.0))

        super.paintEvent(event)
    }
}
