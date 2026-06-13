import Blusher

struct BlueRectangle: View {
    @State var size: Float = 30.0

    var body: some View {
        Rectangle()
            .geometry(Rect(x: 0.0, y: 0.0, width: size, height: size))
            .color(Color(r: 0, g: 0, b: 255, a: 255))
            .onPointerEnter { _ in
                size += 2.0
            }
    }
}

@main
struct LayoutApp: Application {
    var body: some Surface {
        Window {
            Rectangle()
                .geometry(Rect(x: 10.0, y: 10.0, width: 20.0, height: 20.0))
                .color(.red)
                .onPointerEnter { event in
                    print(event)
                }
            Declarative.CenterLayout {
                BlueRectangle()
                Rectangle()
                    .color(.black)
                    .geometry(Rect(x: 0.0, y: 0.0, width: 40.0, height: 10.0))
            }
            .geometry(Rect(x: 20.0, y: 20.0, width: 100.0, height: 100.0))
            .color(.red)
        }
        .size(SizeI(width: 300, height: 300))
    }

    public static func main() {
        let _ = self.applicationMain()
    }
}
