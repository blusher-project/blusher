@_implementationOnly import Swingby
internal import CPango

public class TextLayout {
    public class Line {
        internal var _sbGlyphLine: OpaquePointer? = nil
        private var _runs: [GlyphRun]

        public var baseline: Point {
            get {
                let b = sb_glyph_line_baseline(_sbGlyphLine)
                return Point(x: b?.pointee.x ?? 0.0, y: b?.pointee.y ?? 0.0)
            }
            set {
                var b = sb_point_t(x: newValue.x, y: newValue.y)
                sb_glyph_line_set_baseline(_sbGlyphLine, &b)
            }
        }

        public init() {
            _sbGlyphLine = sb_glyph_line_new()
            _runs = []
        }

        deinit {
            // TODO: Isn't it dangerous? Yes!
            // sb_glyph_line_free(_sbGlyphLine)
        }

        public func appendRun(_ run: GlyphRun) {
            _runs.append(run)
            sb_glyph_line_add_run(_sbGlyphLine, run._sbGlyphRun)
        }
    }

    private var _pangoFontMap: UnsafeMutablePointer<PangoFontMap>?
    private var _pangoContext: OpaquePointer?
    private var _pangoLayout: OpaquePointer?

    private var _text: String = ""
    private var _lines: [Line] = []
    private var _currentFont: Font!
    private var _cursorPosition: Point = Point(x: 0.0, y: 0.0)

    internal var _sbLayout: OpaquePointer? = nil

    public var text: String {
        get { _text }
        set {
            if _text != newValue {
                _text = newValue
                _text.withCString { cStr in
                    pango_layout_set_text(_pangoLayout, cStr, -1)
                }
                self.update()
            }
        }
    }

    public var cursorPosition: Point {
        get { _cursorPosition }
        set { _cursorPosition = newValue }
    }

    public var width: Float {
        get { Float(pango_layout_get_width(_pangoLayout)) }
        set {
            let width = newValue * Pango.scaleF
            let before = pango_layout_get_serial(_pangoLayout)
            pango_layout_set_width(_pangoLayout, Int32(width))
            let after = pango_layout_get_serial(_pangoLayout)
            if before != after {
                self.update()
            }
        }
    }

    public convenience init() {
        let text = ""
        let font = FontLibrary.shared.findFont(family: "Noto Sans")!

        self.init(text, font)
    }

    public init(_ text: String, _ font: Font) {
        _sbLayout = sb_glyph_layout_new()

        _pangoFontMap = pango_ft2_font_map_new()
        _pangoContext = pango_font_map_create_context(_pangoFontMap)
        _pangoLayout = pango_layout_new(_pangoContext)

        _text = text
        _currentFont = font
    }

    deinit {
        // TODO!
    }

    //==================
    // Private Method
    //==================
    private func lineCount() -> Int {
        Int(pango_layout_get_line_count(_pangoLayout))
    }

    private func syncSwingby() {
        let _ = 0
    }

    private func setPangoFont(_ font: Font) {
        let desc = pango_font_description_new()

        pango_font_description_set_family(desc, font.family)
        pango_font_description_set_absolute_size(desc, Double(font.size) * Double(PANGO_SCALE))
        pango_layout_set_font_description(_pangoLayout, desc)

        pango_font_description_free(desc)
    }

    //==================
    // Public Method
    //==================
    public func appendLine(_ line: Line) {
        _lines.append(line)
        sb_glyph_layout_add_line(_sbLayout, line._sbGlyphLine)
    }

    public func update() {
        self.setPangoFont(_currentFont)

        pango_layout_context_changed(_pangoLayout)

        if _sbLayout != nil {
            sb_glyph_layout_clear_lines(_sbLayout)
            _lines = []
        }

        var totalY: Float = 0.0
        for i in 0..<self.lineCount() {
            let line = TextLayout.Line()

            var runCount = 0
            // Count runs.
            let pangoLine: UnsafeMutablePointer<PangoLayoutLine> =
                pango_layout_get_line_readonly(_pangoLayout, Int32(i))
            var it: UnsafeMutablePointer<GSList>? = pangoLine.pointee.runs
            while it != nil {
                runCount += 1
                it = it?.pointee.next
            }

            let metrics = FontMetrics(_currentFont)

            // Fill runs.
            it = pangoLine.pointee.runs
            while it != nil {
                let l = UnsafeMutableRawPointer(it!).assumingMemoryBound(to: GSList.self)
                let item = UnsafeMutableRawPointer(l.pointee.data)
                    .assumingMemoryBound(to: PangoGlyphItem.self)

                /*
                let pangoFont = item.pointee.item.pointee.analysis.font
                let pangoDesc = pango_font_describe(pangoFont)
                print("pango family: \(String(cString: pango_font_description_get_family(pangoDesc)!))")
                */

                let glyphs: UnsafeMutablePointer<PangoGlyphString>? = item.pointee.glyphs
                let run = GlyphRun(count: Int(glyphs!.pointee.num_glyphs), font: self._currentFont)
                for i in 0..<Int(glyphs!.pointee.num_glyphs) {
                    let info = glyphs!.pointee.glyphs[i]

                    let advance: Float = Float(info.geometry.width) / Pango.scaleF

                    // Logger.debug("glyph: \(info.glyph) advance: \(advance) x_offset: \(info.geometry.x_offset / PANGO_SCALE) y_offset: \(info.geometry.y_offset / PANGO_SCALE)")

                    run[i].id = info.glyph
                    run[i].advance = advance
                    run[i].offset.x = Float(info.geometry.x_offset) / Pango.scaleF
                    run[i].offset.y = Float(info.geometry.y_offset) / Pango.scaleF
                }
                it = it?.pointee.next

                line.appendRun(run)
            }
            line.baseline = Point(x: 0.0, y: totalY)
            // line.baseline = Point(x: 0.0, y: metrics.ascent + metrics.descent + metrics.leading)
            totalY += metrics.ascent + metrics.descent + metrics.leading
            self.appendLine(line)
        }
    }
}

//=============
// Pango
//=============

internal enum Pango {
    public static let scaleF: Float = Float(PANGO_SCALE)
    public static let scaleD: Double = Double(PANGO_SCALE)

    public class FontDescription {
        private var _ptr: OpaquePointer!
        private var _family: String = ""
        private var _size: Float = 1.0

        public var cPointer: OpaquePointer {
            _ptr
        }

        public var family: String {
            get { _family }
            set {
                _family = newValue
                pango_font_description_set_family(_ptr, _family)
            }
        }

        public var size: Float {
            get { _size }
            set {
                _size = newValue
                pango_font_description_set_absolute_size(_ptr, Double(_size))
            }
        }

        public init() {
            _ptr = pango_font_description_new()
        }

        deinit {
            pango_font_description_free(_ptr)
        }
    }

    public struct Line {
        private var _cPointer: UnsafePointer<PangoLayoutLine>

        internal init(_ ptr: UnsafePointer<PangoLayoutLine>) {
            _cPointer = ptr
        }
    }

    public struct CursorPosition {
        public var strong: Rect
        public var weak: Rect
    }

    public class Layout {
        private var _pangoFontMap: UnsafeMutablePointer<PangoFontMap>?
        private var _pangoContext: OpaquePointer?
        private var _pangoLayout: OpaquePointer?

        private var _fontDescription: FontDescription
        private var _lines: [Line] = []
        private var _text: String = ""
        private var _textRuns: [(String, Font)] = []

        public var fontDescription: FontDescription {
            get { _fontDescription }
            set {
                _fontDescription = newValue
                _fontDescription.family = newValue.family
                _fontDescription.size = newValue.size
                // pango_layout_set_font_description(_pangoLayout, _fontDescription.cPointer)
            }
        }

        public var lineCount: Int {
            Int(pango_layout_get_line_count(_pangoLayout))
        }

        init() {
            _pangoFontMap = pango_ft2_font_map_new()
            _pangoContext = pango_font_map_create_context(_pangoFontMap)
            _pangoLayout = pango_layout_new(_pangoContext)

            _fontDescription = FontDescription()
        }

        deinit {
            //
        }

        public func getCursorPosition(at index: Int) -> CursorPosition {
            var prStrong = PangoRectangle()
            var prWeak = PangoRectangle()

            pango_layout_get_cursor_pos(_pangoLayout, Int32(index), &prStrong, &prWeak)

            let strong = Rect(
                x: Float(prStrong.x), y: Float(prStrong.y),
                width: Float(prStrong.width), height: Float(prStrong.height)
            )
            let weak = Rect(
                x: Float(prWeak.x), y: Float(prWeak.y),
                width: Float(prWeak.width), height: Float(prWeak.height)
            )
            let cursorPosition = CursorPosition(strong: strong, weak: weak)
            return cursorPosition
        }

        public func layOut() {
            _textRuns = []

            for tr in _textRuns {
                let desc = pango_font_description_new()
                let font = tr.1
                let sizeD = Double(tr.1.size)
                pango_font_description_set_family(desc, font.family)
                pango_font_description_set_absolute_size(desc, sizeD * Double(PANGO_SCALE))
                pango_layout_set_font_description(_pangoLayout, desc)
                pango_font_description_free(desc)

                // pango_layout_context_changed(_pangoLayout)
            }
        }

        public func update() {
            pango_layout_set_font_description(_pangoLayout, _fontDescription.cPointer)

            pango_layout_context_changed(_pangoLayout)

            _lines = []

            for i in 0..<self.lineCount {
                guard let l = pango_layout_get_line_readonly(_pangoLayout, Int32(i)) else { return }
                let line = Line(l)
                _lines.append(line)
            }
        }

        public func appendText(_ text: String, _ font: Font) {
            _textRuns.append((text, font))
        }
    }
}
