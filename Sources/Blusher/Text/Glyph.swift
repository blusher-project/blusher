@_implementationOnly import Swingby

public typealias GlyphID = UInt32

public class GlyphBlock {
    public var runs: [GlyphRun] = []
    public var baseline: Double = 0.0

    public init() {
    }
}

public class GlyphRun {
    internal var _sbGlyphRun: OpaquePointer? = nil
    private let _count: Int

    public var glyphs: [GlyphID] = []
    public var positions: [Point] = []
    public var font: Font

    public var count: Int {
        _count
    }

    public init(count: Int, font: Font) {
        _count = count
        self.font = font

        var sbFont = sb_font_t(path: nil, ttc_index: Int32(font.ttcIndex), size: font.size)

        font.path.withCString { cStr in
            sbFont.path = cStr
        }

        _sbGlyphRun = sb_glyph_run2_new(UInt32(count), &sbFont)
    }

    deinit {
        sb_glyph_run2_free(_sbGlyphRun)
    }

    public func validate() -> Bool {
        if self.glyphs.count != _count || self.positions.count != _count {
            return false
        }

        return true
    }
}
