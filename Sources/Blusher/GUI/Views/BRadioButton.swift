open class BRadioButton: BView {
    private var _label: BView!
    private var _selected: Bool

    public var selected: Bool {
        get { _selected }
        set { _selected = newValue }
    }

    public init(_ label: String, parent: BView) {
        _selected = false

        super.init(parent: parent)

        self.size = Size(width: 80.0, height: 16.0)
        self.renderType = .canvas

        // Label.
        _label = BView(parent: self)
        _label.renderType = .text
        _label.textLayout = TextLayout()
        _label.textLayout?.text = label
        _label.position = Point(x: 16.0, y: 0.0)
        _label.size = Size(width: 80.0 - 16.0, height: 16.0)
    }

    open override func paintEvent(_ event: Event) {
        var paint = Paint()

        let radii = Radii(all: 16.0)
        let rrect = RoundedRect(x: 0.0, y: 0.0, width: 16.0, height: 16.0, radii: radii)
        let inner = RoundedRect(x: 4.0, y: 4.0, width: 8.0, height: 8.0, radii: Radii(all: 8.0))

        paint.fillColor = .silver
        self.canvas?.drawRoundedRect(rrect, paint)

        if (self.selected) {
            paint.fillColor = .black
            self.canvas?.drawRoundedRect(inner, paint)
        }
    }
}
