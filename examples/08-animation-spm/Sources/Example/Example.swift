import Blusher


nonisolated(unsafe) var isRunning: Bool = false

@main
public struct Program {
    class Label: BView {
        //
        init(parent: BView, geometry: Rect, _ text: String) {
            super.init(parent: parent, geometry: geometry)
        }
    }

    class AnimatedBox: BView {
        private var _animation: GeometryAnimation!

        private var _label: BView!

        private let _initialRect: Rect = Rect(x: 0.0, y: 0.0, width: 80.0, height: 20.0)
        private let _finalRect: Rect = Rect(x: 0.0, y: 0.0, width: 300.0, height: 20.0)

        init(parent: BView, geometry: Rect, _ easing: CubicBezier, _ text: String) {
            var initialGeometry = _initialRect
            initialGeometry.position = geometry.position
            var finalGeometry = _finalRect
            finalGeometry.position = geometry.position
            super.init(parent: parent, geometry: initialGeometry)

            _animation = GeometryAnimation(self, _initialRect)
            _animation.easing = easing
            _animation.duration = 2000
            _animation.to = finalGeometry

            _label = BView(parent: self, geometry: Rect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
            _label.renderType = .text
            _label.textLayout = TextLayout()
            _label.textLayout?.text = text

            self.color = Color(r: 1.0, g: 0.0, b: 0.0, a: 1.0)
        }

        func startAnimation() {
            _animation.start()
        }
    }

    public static func main() {
        let app = BApplication(CommandLine.arguments)

        let window = BWindow()
        window.size = SizeI(width: 500, height: 400)

        let view = BView(
            parent: window.body,
            geometry: Rect(x: 0.0, y: 0.0, width: 340.0, height: 400.0)
        )

        let linear = AnimatedBox(
            parent: view,
            geometry: Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0),
            EasingFunction.linear,
            "Linear"
        )
        let ease = AnimatedBox(
            parent: view,
            geometry: Rect(x: 0.0, y: 30.0, width: 1.0, height: 1.0),
            EasingFunction.ease,
            "Ease"
        )
        let easeIn = AnimatedBox(
            parent: view,
            geometry: Rect(x: 0.0, y: 60.0, width: 1.0, height: 1.0),
            EasingFunction.easeIn,
            "EaseIn"
        )
        let easeOut = AnimatedBox(
            parent: view,
            geometry: Rect(x: 0.0, y: 90.0, width: 1.0, height: 1.0),
            EasingFunction.easeOut,
            "EaseOut"
        )
        let easeInOut = AnimatedBox(
            parent: view,
            geometry: Rect(x: 0.0, y: 120.0, width: 1.0, height: 1.0),
            EasingFunction.easeInOut,
            "EaseInOut"
        )

        let toggleButton = BButton(
            parent: view,
            "Start"
        )
        toggleButton.geometry = Rect(x: 100.0, y: 250.0, width: 60.0, height: 30.0)

        let warning = BPopup(at: toggleButton.absolutePosition, window)
        warning.size = SizeI(width: 80, height: 30)
        warning.rootViewColor = Color(r: 0.0, g: 0.0, b: 0.0, a: 1.0)

        toggleButton.onPointerClick += { event in
            if !isRunning {
                linear.startAnimation()
                ease.startAnimation()
                easeIn.startAnimation()
                easeOut.startAnimation()
                easeInOut.startAnimation()
                isRunning = true
            } else {
                warning.grabbable = true
                warning.show()
                warning.grab(for: .button)
            }
        }

        window.show()

        let _ = app.exec()
    }
}
