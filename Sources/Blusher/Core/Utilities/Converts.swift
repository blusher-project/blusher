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
