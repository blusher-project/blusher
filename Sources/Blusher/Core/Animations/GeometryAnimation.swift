public class GeometryAnimation: PropertyAnimation<Rect> {
    public override init(_ target: BView, _ initial: Rect) {
        super.init(target, initial)

        super.initial = Rect(
            x: target.geometry.x, y: target.geometry.y,
            width: target.geometry.width, height: target.geometry.height
        )
        super.from = Rect(
            x: target.geometry.x, y: target.geometry.y,
            width: target.geometry.width, height: target.geometry.height
        )
        super.to = Rect(
            x: target.geometry.x, y: target.geometry.y,
            width: target.geometry.width, height: target.geometry.height
        )
        super.last = Rect(
            x: target.geometry.x, y: target.geometry.y,
            width: target.geometry.width, height: target.geometry.height
        )
    }

    public override func setProperty(_ t: Float) {
        if super.state == .running {
            super.target.geometry = Rect(
                x: Self.lerp(last.x, to.x, t),
                y: Self.lerp(last.y, to.y, t),
                width: Self.lerp(last.width, to.width, t),
                height: Self.lerp(last.height, to.height, t)
            )
        } else if super.state == .reversing {
            super.target.geometry = Rect(
                x: last.x + (from.x - last.x) * t,
                y: last.y + (from.y - last.y) * t,
                width: last.width + (from.width - last.width) * t,
                height: last.height + (from.height - last.height) * t
            )
        }
    }
}
