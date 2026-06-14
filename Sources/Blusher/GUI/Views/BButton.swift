open class BButton: BView {
    private var _text: String
    private var _textLayout: TextLayout
    private var _label: BView!
    private var _pressed: Bool = false

    public var text: String {
        get { _text }
        set {
            _text = newValue
            _textLayout.text = newValue
        }
    }

    public init(parent: BView, _ text: String) {
        _text = text
        _textLayout = TextLayout()
        super.init(parent: parent, geometry: Rect(x: 0.0, y: 0.0, width: 60.0, height: 30.0))

        self.renderType = .canvas

        _label = BView(parent: self, geometry: Rect(x: 0.0, y: 0.0, width: 40.0, height: 30.0))
        _label.renderType = .text
        _label.textLayout = _textLayout

        self.text = text
    }

    private var defaultBottom: Rect {
        Rect(x: 5.0, y: 5.0, width: self.size.width - 5.0, height: self.size.height - 5.0)
    }

    private var defaultTop: Rect {
        Rect(x: 0.0, y: 0.0, width: self.size.width - 5.0, height: self.size.height - 5.0)
    }

    private var pressedBottom: Rect {
        Rect(x: 0.0, y: 0.0, width: self.size.width - 5.0, height: self.size.height - 5.0)
    }

    private var pressedTop: Rect {
        Rect(x: 5.0, y: 5.0, width: self.size.width - 5.0, height: self.size.height - 5.0)
    }

    public override func paintEvent(_ event: Event) {
        var paint = Paint()

        if !_pressed {
            paint.fillColor = .black
            let bottom = self.defaultBottom
            self.canvas?.drawRect(bottom, paint)

            paint.fillColor = Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0)
            let top = self.defaultTop
            self.canvas?.drawRect(top, paint)
        } else {
            paint.fillColor = .black
            let bottom = self.pressedBottom
            self.canvas?.drawRect(bottom, paint)

            paint.fillColor = Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0)
            let top = self.pressedTop
            self.canvas?.drawRect(top, paint)
        }
    }

    public override func pointerPressEvent(_ event: PointerEvent) {
        _pressed = true
        self.surface.update()
    }

    public override func pointerReleaseEvent(_ event: PointerEvent) {
        _pressed = false
        self.surface.update()
    }
}
