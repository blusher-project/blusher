@_implementationOnly import Swingby
internal import CPango

public class TextLayout {
    public class Line {
        internal var _sbGlyphLine: OpaquePointer? = nil
        private var _runs: [GlyphRun]

        public init() {
            _sbGlyphLine = sb_glyph_line_new()
            _runs = []
        }

        deinit {
            // TODO: Isn't it dangerous?
            sb_glyph_line_free(_sbGlyphLine)
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
    private var _glyphRuns: [GlyphRun] = []

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

            // Fill runs.
            it = pangoLine.pointee.runs
            while it != nil {
                let l = UnsafeMutableRawPointer(it!).assumingMemoryBound(to: GSList.self)
                let item = UnsafeMutableRawPointer(l.pointee.data)
                    .assumingMemoryBound(to: PangoGlyphItem.self)

                let pangoFont = item.pointee.item.pointee.analysis.font
                let pangoDesc = pango_font_describe(pangoFont)
                print("pango family: \(String(cString: pango_font_description_get_family(pangoDesc)!))")

                let glyphs: UnsafeMutablePointer<PangoGlyphString>? = item.pointee.glyphs
                let run = GlyphRun(count: Int(glyphs!.pointee.num_glyphs), font: self._currentFont)
                for i in 0..<Int(glyphs!.pointee.num_glyphs) {
                    let info = glyphs!.pointee.glyphs[i]

                    let advance: Float = Float(info.geometry.width) / Float(PANGO_SCALE)

                    Logger.debug("glyph: \(info.glyph) advance: \(advance) x_offset: \(info.geometry.x_offset / PANGO_SCALE) y_offset: \(info.geometry.y_offset / PANGO_SCALE)")

                    run[i].id = info.glyph
                    run[i].advance = advance
                    run[i].offset.x = Float(info.geometry.x_offset) / Float(PANGO_SCALE)
                    run[i].offset.y = Float(info.geometry.y_offset) / Float(PANGO_SCALE)
                }
                it = it?.pointee.next

                line.appendRun(run)
            }
            self.appendLine(line)
        }
    }
}

//=============
// Pango
//=============

internal enum Pango {
    public class Layout {
        private var _pangoFontMap: UnsafeMutablePointer<PangoFontMap>?
        private var _pangoContext: OpaquePointer?
        private var _pangoLayout: OpaquePointer?
        private var _textRuns: [(String, Font)] = []

        init() {
            _pangoFontMap = pango_ft2_font_map_new()
            _pangoContext = pango_font_map_create_context(_pangoFontMap)
            _pangoLayout = pango_layout_new(_pangoContext)
        }

        deinit {
            //
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

        public func appendText(_ text: String, _ font: Font) {
            _textRuns.append((text, font))
        }
    }
}
