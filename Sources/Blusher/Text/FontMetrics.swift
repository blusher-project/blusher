@_implementationOnly import Swingby

public class FontMetrics {
    public var ascent: Float = -1.0
    public var descent: Float = -1.0
    public var leading: Float = -1.0
    public var capHeight: Float = -1.0
    public var xHeight: Float = -1.0

    public init(_ font: Font) {
        var sbFont = font.path.withCString { ptr in
            sb_font_t(
                path: ptr,
                ttc_index: Int32(font.ttcIndex),
                size: font.size
            )
        }

        guard let sbFontMetrics = sb_font_metrics_new(&sbFont) else {
            Logger.error("sb_font_metrics_new returned a null pointer!")
            return
        }

        self.ascent = sbFontMetrics.pointee.ascent
        self.descent = sbFontMetrics.pointee.descent
        self.leading = sbFontMetrics.pointee.leading
        self.capHeight = sbFontMetrics.pointee.cap_height
        self.xHeight = sbFontMetrics.pointee.x_height

        sb_font_metrics_free(sbFontMetrics)
    }
}
