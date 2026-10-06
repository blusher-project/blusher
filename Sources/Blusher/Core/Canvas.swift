@_implementationOnly import Swingby

func colorToSbColor(_ color: Color) -> sb_color_t {
    let sb_color_t = sb_color_t(r: color.r, g: color.g, b: color.b, a: color.a)

    return sb_color_t
}

func paintToSbPaint(_ paint: Paint) -> OpaquePointer {
    var fillColor = colorToSbColor(paint.fillColor)
    var strokeColor = colorToSbColor(paint.strokeColor)
    let strokeWidth = paint.strokeWidth
    let sbStrokeSizing = switch paint.strokeSizing {
    case .inner: SB_STROKE_SIZING_INNER
    case .center: SB_STROKE_SIZING_CENTER
    case .outer: SB_STROKE_SIZING_OUTER
    }

    let sbPaint = sb_paint_new()
    sb_paint_set_fill_color(sbPaint, &fillColor)
    sb_paint_set_stroke_color(sbPaint, &strokeColor)
    sb_paint_set_stroke_width(sbPaint, strokeWidth)
    sb_paint_set_stroke_sizing(sbPaint, sbStrokeSizing)

    return sbPaint!
}

public class Canvas {
    private var _sbCanvas: OpaquePointer? = nil

    internal init(_ sbCanvas: OpaquePointer) {
        _sbCanvas = sbCanvas
    }

    public func drawRect(_ rect: Rect, _ paint: Paint) {
        var sbRect = sb_rect_t(
            position: sb_point_t(x: Float(rect.x), y: Float(rect.y)),
            size: sb_size_t(width: Float(rect.width), height: Float(rect.height))
        )
        let sbPaint = paintToSbPaint(paint)

        if let sbCanvas = _sbCanvas {
            sb_canvas_draw_rect(sbCanvas, &sbRect, sbPaint)
        }

        sb_paint_free(sbPaint)
    }

    public func drawRoundedRect(_ rrect: RoundedRect, _ paint: Paint) {
        let sbRoundedRect = sb_rounded_rect_t(
            position: sb_point_t(x: Float(rrect.position.x), y: Float(rrect.position.y)),
            size: sb_size_t(width: Float(rrect.size.width), height: Float(rrect.size.height)),
            radii: sb_radii_t(
                top_left: Float(rrect.radii.topLeft),
                top_right: Float(rrect.radii.topRight),
                bottom_right: Float(rrect.radii.bottomRight),
                bottom_left: Float(rrect.radii.bottomLeft)
            )
        )
        let sbPaint = paintToSbPaint(paint)

        if let sbCanvas = _sbCanvas {
            sb_canvas_draw_rounded_rect(sbCanvas, sbRoundedRect, sbPaint)
        }

        sb_paint_free(sbPaint)
    }

    public func drawLine(_ p1: Point, _ p2: Point, _ paint: Paint) {
        if let sbCanvas = _sbCanvas {
            var sbP1 = sb_point_t(x: Float(p1.x), y: Float(p1.y))
            var sbP2 = sb_point_t(x: Float(p2.x), y: Float(p2.y))
            let sbPaint = paintToSbPaint(paint)

            sb_canvas_draw_line(sbCanvas, &sbP1, &sbP2, sbPaint)

            sb_paint_free(sbPaint)
        }
    }

    public func drawLine(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ paint: Paint) {
        self.drawLine(Point(x: x1, y: y1), Point(x: x2, y: y2), paint)
    }

    public func save() {
        sb_canvas_save(_sbCanvas)
    }

    public func restore() {
        sb_canvas_restore(_sbCanvas)
    }

    public func clipRect(_ rect: Rect) {
        let sbRect = sb_rect_t(
            position: sb_point_t(x: Float(rect.x), y: Float(rect.y)),
            size: sb_size_t(width: Float(rect.width), height: Float(rect.height))
        )
        sb_canvas_clip_rect(_sbCanvas, sbRect)
    }

    public func clipRoundedRect(_ rrect: RoundedRect) {
        let sbRoundedRect = sb_rounded_rect_t(
            position: sb_point_t(x: Float(rrect.position.x), y: Float(rrect.position.y)),
            size: sb_size_t(width: Float(rrect.size.width), height: Float(rrect.size.height)),
            radii: sb_radii_t(
                top_left: Float(rrect.radii.topLeft),
                top_right: Float(rrect.radii.topRight),
                bottom_right: Float(rrect.radii.bottomRight),
                bottom_left: Float(rrect.radii.bottomLeft)
            )
        )
        sb_canvas_clip_rounded_rect(_sbCanvas, sbRoundedRect)
    }
}
