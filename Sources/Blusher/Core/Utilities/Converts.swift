@_implementationOnly import Swingby

internal func rectToSbRect(_ rect: Rect) -> sb_rect_t {
    return sb_rect_t(
        position: sb_point_t(x: Float(rect.x), y: Float(rect.y)),
        size: sb_size_t(width: Float(rect.width), height: Float(rect.height))
    )
}

internal func rectFromSbRect(_ sbRect: sb_rect_t) -> Rect {
    return Rect(
        x: Double(sbRect.position.x),
        y: Double(sbRect.position.y),
        width: Double(sbRect.size.width),
        height: Double(sbRect.size.height)
    )
}

internal func rectIToSbRectI(_ rect: RectI) -> sb_rect_i_t {
    return sb_rect_i_t(
        position: sb_point_i_t(x: Int32(rect.x), y: Int32(rect.y)),
        size: sb_size_i_t(width: Int32(rect.width), height: Int32(rect.height))
    )
}

internal func pointIToSbPointI(_ point: PointI) -> sb_point_i_t {
    return sb_point_i_t(x: Int32(point.x), y: Int32(point.y))
}
