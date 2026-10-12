import Blusher

class TextExampleView: BView {
    public override init() {
        super.init()

        self.size = Size(width: 300.0, height: 300.0)
        self.color = .transparent

        // Text area.
        let textArea = BView(
            parent: self,
            geometry: Rect(x: 0.0, y: 0.0, width: 340.0, height: 400.0)
        )
        textArea.color = Color(r: 0.8, g: 0.8, b: 0.8, a: 1.0)

        let font = FontLibrary.shared.findFont(family: "serif", size: 12.5)

        let textView = BTextView(lorem, font!, parent: textArea)
        textView.text = lorem

        // Button panel.
        let buttonPanel = BView(
            parent: self,
            geometry: Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        )
        buttonPanel.layout = VBoxLayout()

        self.onResize += { event in
            let geometry = Rect(
                x: 0.0,
                y: 0.0,
                width: event.size.width - 100.0,
                height: event.size.height
            )
            textArea.geometry = geometry
            textView.geometry = geometry

            buttonPanel.geometry = Rect(
                x: textArea.size.width, y: 0.0, width: 100.0, height: event.size.height,
            )
        }

        // Buttons.
        let loremIpsum = BButton("Lorem Ipsum", parent: buttonPanel)
        loremIpsum.onPointerClick += { evt in
            textView.text = lorem
        }
        let hindiButton = BButton("हिन्दी", parent: buttonPanel)
        hindiButton.onPointerClick += { evt in
            textView.text = hindi
        }
        let arabicButton = BButton("العربية", parent: buttonPanel)
        arabicButton.onPointerClick += { evt in
            textView.text = arabic
        }
        let japaneseButton = BButton("日本語", parent: buttonPanel)
        japaneseButton.onPointerClick += { evt in
            textView.text = japanese
        }
    }
}
