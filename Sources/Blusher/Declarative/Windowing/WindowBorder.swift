public struct WindowBorder: View, WindowDecoration {
    public static var thickness: Double {
        get { 1.0 }
        set { return }
    }

    public var body: some View {
        Rectangle()
            .color(Color(r: 0, g: 0, b: 0, a: 255))
            .radius(Radius(all: 8.0))
    }
}
