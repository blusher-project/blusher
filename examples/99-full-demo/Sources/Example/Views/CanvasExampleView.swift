import Blusher

class CanvasExampleView: BView {
    public override init() {
        super.init()

        self.renderType = .canvas
    }

    override func paintEvent(_ event: Event) {
        var paint = Paint()
        paint.fillColor = .red
        paint.strokeWidth = 3.0
        paint.strokeColor = Color(r: 0.0, g: 0.0, b: 1.0, a: 1.0)

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
