@_implementationOnly import Swingby

public struct Glyph {
    public var id: UInt32 = 0
    public var advance: Float = 0.0
    public var offset: Point = Point(x: 0.0, y: 0.0)

    public init(id: UInt32) {
        self.id = id
    }
}

public typealias GlyphID = UInt32

public class GlyphRun2 {
    private var _sbGlyphRun: OpaquePointer? = nil
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

    public func validate() -> Bool {
        if self.glyphs.count != _count || self.positions.count != _count {
            return false
        }

        return true
    }
}

public class GlyphBlock {
    public var runs: [GlyphRun] = []
    public var baseline: Double = 0.0

    public init() {
    }
}

//==================
// Legacy API
//==================

public class GlyphRun {
    internal var _sbGlyphRun: OpaquePointer? = nil
    private var _glyphBuffer: [Glyph] = []
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

    public subscript(_ index: Int) -> Glyph {
        get {
            return _glyphBuffer[index]
        }
        set {
            _glyphBuffer[index] = newValue

            if let cGlyphs = sb_glyph_run_glyphs(_sbGlyphRun) {
                let cGlyph = cGlyphs + index
                cGlyph.pointee.id = newValue.id
                cGlyph.pointee.advance = newValue.advance
                cGlyph.pointee.offset.x = Float(newValue.offset.x)
                cGlyph.pointee.offset.y = Float(newValue.offset.y)
            }
        }
    }
}
