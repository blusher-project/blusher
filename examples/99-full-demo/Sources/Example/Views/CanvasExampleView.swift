import Blusher

class CanvasExampleView: BView {
    private var _radioButtonGroup: BView!
    private var _radioInner: BRadioButton? = nil
    private var _radioCenter: BRadioButton? = nil
    private var _strokeSizing: StrokeSizing = .inner

    public override init() {
        super.init()

        self.renderType = .canvas

        _radioButtonGroup = BView(parent: self)
        _radioButtonGroup.geometry = Rect(x: 120.0, y: 10.0, width: 100.0, height: 50.0)
        var layout = VBoxLayout()
        layout.spacing = 4.0
        _radioButtonGroup.layout = layout
        // Radio buttons.
        _radioInner = BRadioButton("Inner", parent: _radioButtonGroup)
        _radioCenter = BRadioButton("Center", parent: _radioButtonGroup)

        _radioInner?.onPointerClick += { [weak self] evt in
            if self?._radioCenter?.selected == true {
                self?._radioCenter?.selected = false
            }
            self?._radioInner?.selected = true

            self?._strokeSizing = .inner

            self?.surface?.update()
        }
        _radioCenter?.onPointerClick += { [weak self] evt in
            if self?._radioInner?.selected == true {
                self?._radioInner?.selected = false
            }
            self?._radioCenter?.selected = true

            self?._strokeSizing = .center

            self?.surface?.update()
        }
    }

    override func paintEvent(_ event: Event) {
        var paint = Paint()
        paint.fillColor = .red
        paint.strokeWidth = 3.0
        paint.strokeColor = Color(r: 0.0, g: 0.0, b: 1.0, a: 1.0)
        paint.strokeSizing = _strokeSizing

        let rrect = RoundedRect(x: 10.0, y: 10.0, width: 100.0, height: 100.0,
            radii: Radii(all: 15.0))

        self.canvas?.drawRoundedRect(rrect, paint)

        paint.fillColor = .black
        let rect = Rect(x: 50.0, y: 50.0, width: 100.0, height: 100.0)
        self.canvas?.save()
        self.canvas?.clipRoundedRect(rrect)
        self.canvas?.drawRect(rect, paint)
        self.canvas?.restore()

        super.paintEvent(event)
    }
}
