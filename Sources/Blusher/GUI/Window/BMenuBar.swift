public class BMenuBar: BView {
    private class View: BView {
        init(menuBar: BMenuBar, title: String) {
            super.init(parent: menuBar, geometry: Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
            self.renderType = .text
            self.textLayout = TextLayout()
            self.textLayout?.text = title

            self.size.width = 30.0
        }
    }

    private var _menu: Menu

    public var menu: Menu {
        get { _menu }
        set {
            _menu = newValue

            self.update()
        }
    }

    public init(_ menu: Menu, window: BWindow) {
        _menu = menu

        super.init(
            surface: window.surface,
            geometry: Rect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
        )

        window.setMenuBar(self)

        self.layout = HBoxLayout()

        self.update()
    }

    private func update() {
        // Clear children.
        while self.children.count > 0 {
            let _ = self.removeChild(self.children.last!)
        }

        // Push children.
        self.menu.items.forEach { menuItem in
            let _ = View(menuBar: self, title: menuItem.title)
        }
    }
}
