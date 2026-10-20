@_implementationOnly import Swingby
internal import CPango

public class TextLayout {
    public class Line {
        private var _runs: [GlyphRun]
        private var _baseline: Double = 0.0

        public var boundingRect: Rect = Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)

        public var runs: [GlyphRun] {
            _runs
        }

        public var baseline: Double {
            get {
                _baseline
            }
            set {
                _baseline = newValue
            }
        }

        public init() {
            _runs = []
        }

        deinit {
            // TODO: Isn't it dangerous? Yes!
            // sb_glyph_line_free(_sbGlyphLine)
        }

        public func appendRun(_ run: GlyphRun) {
            _runs.append(run)
        }
    }

    private var _pangoContext: OpaquePointer?
    private var _pangoLayout: OpaquePointer?

    private var _text: String = ""
    private var _currentFont: Font!
    private var _cursorPosition: Point = Point(x: 0.0, y: 0.0)

    public var lines: [Line] = []
    public var updateCallback: (() -> Void)? = nil

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

    public var font: Font {
        get { _currentFont }
        set { _currentFont = newValue }
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

    // TODO: Not working.
    public init(_ text: String, _ font: Font) {
        let pangoFontMap = Pango.FontMap.current
        _pangoContext = pango_font_map_create_context(pangoFontMap.cPointer)
        _pangoLayout = pango_layout_new(_pangoContext)

        // This is important. If this feature is on, the positions of glyphs
        // are rounded into integer. So glyphs looks unaligned specifically in
        // small font size.
        pango_context_set_round_glyph_positions(_pangoContext, 0)

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

    private func setPangoFont(_ font: Font) {
        let desc = pango_font_description_new()

        pango_font_description_set_family(desc, font.family)
        pango_font_description_set_absolute_size(desc, Double(font.size) * Double(PANGO_SCALE))
        pango_layout_set_font_description(_pangoLayout, desc)

        pango_font_description_free(desc)
    }

    private func getBaseline(_ lineIter: OpaquePointer) -> Double {
        let pangoBaseline = pango_layout_iter_get_baseline(lineIter)
        let baseline = Double(pangoBaseline) / Pango.scaleD
        return baseline
    }

    //==================
    // Public Method
    //==================
    public func update() {
        self.setPangoFont(_currentFont)

        pango_layout_context_changed(_pangoLayout)

        self.lines = []

        let pangoIter = pango_layout_get_iter(_pangoLayout)
        if pangoIter == nil {
            Logger.error("pango_layout_get_iter() == nil")
            return
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

            var x = 0.0
            let baseline = self.getBaseline(pangoIter!)
            line.baseline = baseline

            var pangoRect = PangoRectangle()
            pango_layout_line_get_extents(pangoLine, nil, &pangoRect)
            line.boundingRect.position.x = Double(pangoRect.x) / Pango.scaleD
            line.boundingRect.position.y = Double(pangoRect.y) / Pango.scaleD + line.baseline
            line.boundingRect.size.width = Double(pangoRect.width) / Pango.scaleD
            line.boundingRect.size.height = Double(pangoRect.height) / Pango.scaleD
            // Fill runs.
            it = pangoLine.pointee.runs
            while it != nil {
                let l = UnsafeMutableRawPointer(it!).assumingMemoryBound(to: GSList.self)
                let item = UnsafeMutableRawPointer(l.pointee.data)
                    .assumingMemoryBound(to: PangoGlyphItem.self)

                // Get fallback font info.
                let pangoFont = item.pointee.item.pointee.analysis.font!
                let description = Pango.FontDescription(fromPangoFont: pangoFont)
                let font = FontLibrary.shared.findFont(
                    family: description.family,
                    size: _currentFont.size
                )
                if font != nil {
                    _currentFont = font
                }

                let glyphs: UnsafeMutablePointer<PangoGlyphString>? = item.pointee.glyphs
                let run = GlyphRun(
                    count: Int(glyphs!.pointee.num_glyphs),
                    font: _currentFont
                )
                for i in 0..<Int(glyphs!.pointee.num_glyphs) {
                    let info = glyphs!.pointee.glyphs[i]

                    let advance = Double(info.geometry.width) / Pango.scaleD

                    // Logger.debug("glyph: \(info.glyph) advance: \(advance) x_offset: \(info.geometry.x_offset / PANGO_SCALE) y_offset: \(info.geometry.y_offset / PANGO_SCALE)")

                    let offset = Point(
                        x: Double(info.geometry.x_offset) / Pango.scaleD,
                        y: Double(info.geometry.y_offset) / Pango.scaleD
                    )

                    run.glyphs.append(info.glyph)
                    run.positions.append(Point(
                        x: x + (offset.x),
                        y: (offset.y) + baseline
                    ))
                    x += advance
                }
                if !run.validate() {
                    Logger.error("Run count incorrect!")
                }
                it = it?.pointee.next

                line.appendRun(run)
            }
            self.lines.append(line)
            pango_layout_iter_next_line(pangoIter)
        }

        self.updateCallback?()
    }

    public func toGlyphBlock() -> GlyphBlock {
        let block = GlyphBlock()

        for line in self.lines {
            if block.baseline == 0.0 {
                block.baseline = line.baseline
            }

            for run in line.runs {
                block.runs.append(run)
            }
        }

        return block
    }
}

extension TextLayout: CustomStringConvertible {
    public var description: String {
        return "Blusher.TextLayout(lines: \(self.lines.count), text: \(self.text))"
    }
}

//=============
// Pango
//=============

internal enum Pango {
    public static let scaleF: Float = Float(PANGO_SCALE)
    public static let scaleD: Double = Double(PANGO_SCALE)

    public class FontMap {
        private var _pangoFontMap: UnsafeMutablePointer<PangoFontMap>? = nil

        public static var current: Pango.FontMap {
            if BApplication.shared.pangoFontMap == nil {
                BApplication.shared.pangoFontMap = Pango.FontMap()
            }
            return BApplication.shared.pangoFontMap!
        }

        public var cPointer: UnsafeMutablePointer<PangoFontMap>? {
            return _pangoFontMap
        }

        private init() {
            _pangoFontMap = pango_ft2_font_map_new()
        }

        deinit {
            Logger.debug("Pango.FontMap: Destroying ...")
            g_object_unref(_pangoFontMap)
        }
    }

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

        public init(fromPangoFont pangoFont: UnsafeMutablePointer<PangoFont>) {
            _ptr = pango_font_describe(pangoFont)

            let family = pango_font_description_get_family(_ptr)
            if family != nil {
                _family = String(cString: family!)
            }
        }

        deinit {
            pango_font_description_free(_ptr)
        }
    }

    public class Font {
        private var _pangoFont: UnsafeMutablePointer<PangoFont>

        public init(_ pangoFont: UnsafeMutablePointer<PangoFont>) {
            _pangoFont = pangoFont
        }

        public func filePath() -> String? {
            // Type cast.
            let pangoFcFont = UnsafeMutableRawPointer(_pangoFont)
                .assumingMemoryBound(to: PangoFcFont.self)

            // Get Fontconfig pattern.
            guard let fcPattern = pango_fc_font_get_pattern(pangoFcFont) else { return nil }

            var path: UnsafeMutablePointer<FcChar8>? = nil
            let result = FcPatternGetString(fcPattern, FC_FILE, 0, &path)
            if result == FcResultNoMatch {
                return nil
            }

            return String(
                cString: UnsafeMutableRawPointer(path!).assumingMemoryBound(to: CChar.self)
            )
        }

        public func ttcIndex() -> Int {
            // Type cast.
            let pangoFcFont = UnsafeMutableRawPointer(_pangoFont)
                .assumingMemoryBound(to: PangoFcFont.self)

            // Get Fontconfig pattern.
            guard let fcPattern = pango_fc_font_get_pattern(pangoFcFont) else { return 0 }

            var index: Int32 = 0
            FcPatternGetInteger(fcPattern, FC_INDEX, 0, &index)

            return Int(index)
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
        private var _textRuns: [(String, Blusher.Font)] = []

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
                x: Double(prStrong.x), y: Double(prStrong.y),
                width: Double(prStrong.width), height: Double(prStrong.height)
            )
            let weak = Rect(
                x: Double(prWeak.x), y: Double(prWeak.y),
                width: Double(prWeak.width), height: Double(prWeak.height)
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

        public func appendText(_ text: String, _ font: Blusher.Font) {
            _textRuns.append((text, font))
        }
    }
}
