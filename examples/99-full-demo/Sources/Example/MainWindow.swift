import Blusher

class MainWindow: BWindow {
    public var tabView: BTabView!

    init() {
        super.init()

        self.size = SizeI(width: 500, height: 400)

        self.tabView = BTabView(self.body)

        self.body.onResize += { [self] event in
            self.tabView.size = event.size
        }

        self.tabView.addItem(BTabViewItem(title: "Text", view: TextExampleView()))
        self.tabView.addItem(BTabViewItem(title: "Image", view: ImageExampleView()))
    }
}
