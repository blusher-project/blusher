public class BTabViewItem {
    public var title: String
    public var view: BView? = nil

    public init(title: String, view: BView) {
        self.title = title
        self.view = view
    }
}

open class BTabView: BView {
    class TabButtonGroup: BView {
        override init() {
            super.init()

            self.size.width = 130.0
            self.size.height = 24.0
            self.color = .transparent

            self.layout = HBoxLayout()
        }
    }

    class TabButton: BView {
        private var _index: Int
        private var _title: String

        internal var index: Int { _index }

        init(_ title: String, index: Int, parent: TabButtonGroup) {
            _index = index
            _title = title

            super.init(parent: parent, geometry: Rect(x: 0.0, y: 0.0, width: 36.0, height: 24.0))

            self.renderType = .text
            self.textLayout = TextLayout()
            self.textLayout?.text = title
        }

        override func pointerEnterEvent(_ event: PointerEvent) {
            super.pointerEnterEvent(event)
        }

        override func pointerClickEvent(_ event: PointerEvent) {
            super.pointerClickEvent(event)
        }
    }

    class Frame: BView {
        init(parent: BView) {
            super.init(parent: parent)

            self.renderType = .canvas
        }

        func setTabButtonGroup(_ buttonGroup: TabButtonGroup) {
            buttonGroup.parent = self
        }

        override func paintEvent(_ event: Event) {
            self.canvas?.clear(.transparent)

            var paint = Paint()
            paint.strokeWidth = 3.0
            paint.strokeColor = .gray

            let roundedRect = RoundedRect(
                x: 0.0, y: 0.0,
                width: self.geometry.width, height: self.geometry.height,
                radii: Radii(all: 4.0)
            )

            self.canvas?.save()
            // self.canvas?.clipRoundedRect(roundedRect)
            self.canvas?.drawRoundedRect(roundedRect, paint)
            self.canvas?.restore()

            super.paintEvent(event)
        }
    }

    //===================
    // Private Members
    //===================

    private var _frameView: Frame!
    private var _tabButtons: TabButtonGroup!
    private var _itemView: BView!
    private var _tabIndex: Int = 0

    //=====================
    // Private Properties
    //=====================

    private var _itemViewGeometry: Rect {
        let geometry = Rect(
            x: 0.0, y: 24.0,
            width: self.size.width, height: self.size.height - 24.0
        )
        return geometry
    }

    //====================
    // Public Properties
    //====================

    public var items: [BTabViewItem] = []

    public init(_ parent: BView) {
        super.init(parent: parent, geometry: Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))

        self.size = Size(width: 100.0, height: 100.0)
        self.layout = FillLayout()
        self.layout?.insets = Insets(all: 12.0)

        _frameView = Frame(parent: self)

        _tabButtons = TabButtonGroup()

        _frameView.setTabButtonGroup(_tabButtons)

        _itemView = BView(parent: _frameView, geometry: self._itemViewGeometry)
        _itemView.color = .transparent
        _itemView.layout = FillLayout()
    }

    public func addItem(_ item: BTabViewItem) {
        if item.view?.parent == nil {
            item.view?.parent = _itemView
        }
        self.items.append(item)
        if self.items.count > 1 {
            item.view?.isVisible = false
        }

        let button = TabButton(item.title, index: self.items.count - 1, parent: _tabButtons)
        button.onPointerClick += { [self] event in
            self.activate(at: button.index)
        }
    }

    public func activate(at index: Int) {
        // Prevent overflow.
        if index >= self.items.count {
            return
        }
        // No items.
        if self.items.count == 0 {
            return
        }
        let prevIndex = _tabIndex
        _tabIndex = index
        let prevItem = self.items[prevIndex]
        prevItem.view?.isVisible = false

        self.items[index].view?.isVisible = true
    }

    public func previous() {
        if _tabIndex == 0 {
            return
        }
        self.activate(at: _tabIndex - 1)
    }

    public func next() {
        if _tabIndex >= self.items.count {
            return
        }
        self.activate(at: _tabIndex + 1)
    }

    override open func resizeEvent(_ event: ResizeEvent) {
        // _frameView.size = event.size
        _tabButtons.size.width = event.size.width
        _itemView.geometry = _itemViewGeometry

        self.layingOut()

        super.resizeEvent(event)
    }
}
