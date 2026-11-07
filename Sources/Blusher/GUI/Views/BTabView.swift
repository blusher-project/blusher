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
        public override var preferredSize: Size? {
            var total = 0.0

            for button in self.children {
                total += button.preferredSize?.width ?? 1.0
            }

            return Size(width: total, height: 24.0)
        }

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
        private var _label: BLabel!
        private weak var _buttonGroup: TabButtonGroup? = nil

        internal var index: Int { _index }

        public override var preferredSize: Size? {
            Size(
                width: (_label?.preferredSize?.width ?? 1.0) + 4.0,
                height: (_label?.preferredSize?.height ?? 24.0) + 4.0
            )
        }

        init(_ title: String, index: Int, parent: TabButtonGroup) {
            _index = index
            _title = title
            _buttonGroup = parent

            super.init(parent: parent, geometry: Rect(x: 0.0, y: 0.0, width: 36.0, height: 24.0))

            self.renderType = .canvas

            _label = BLabel(title, parent: self)

            var layout = FlexboxLayout()
            layout.flexDirection = .row
            layout.alignItems = .center
            layout.justifyContent = .center
            self.layout = layout
        }

        override func pointerEnterEvent(_ event: PointerEvent) {
            super.pointerEnterEvent(event)
        }

        override func pointerClickEvent(_ event: PointerEvent) {
            super.pointerClickEvent(event)
        }

        override func paintEvent(_ event: Event) {
            var paint = Paint()
            paint.fillColor = .silver
            paint.strokeColor = .gray
            paint.strokeWidth = 3.0

            let rrect = RoundedRect(
                x: 0.0,
                y: 0.0,
                width: self.preferredSize?.width ?? 10.0,
                height: self.preferredSize?.height ?? 10.0,
                radii: Radii(all: 0.0)
            )

            self.canvas?.drawRoundedRect(rrect, paint)
        }
    }

    class Frame: BView {
        init(parent: BView) {
            super.init(parent: parent)

            self.renderType = .canvas

            self.layout = FillLayout()
            self.layout?.insets = Insets(all: 3.0)
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

    //==============================
    // Private Stored Properties
    //==============================

    private var _frameView: Frame!
    private var _tabButtons: TabButtonGroup!
    private var _itemView: BView!
    private var _tabIndex: Int = 0

    //===============================
    // Private Computed Properties
    //===============================

    private var _itemViewGeometry: Rect {
        let geometry = Rect(
            x: 0.0, y: 24.0,
            width: self.size.width, height: self.size.height - 24.0
        )
        return geometry
    }

    private var _frameGeometry: Rect {
        let insets = 12.0

        let x = insets
        let y = insets
        let width = self.size.width - (insets * 2.0)
        let height = self.size.height - (insets * 2.0)

        return Rect(x: x, y: y, width: width, height: height)
    }

    private var _tabButtonGroupPosition: Point {
        let a = self.size.width / 2.0
        let b = (_tabButtons.preferredSize?.width ?? 10.0) / 2.0
        let x = a - b
        let y = 4.0

        return Point(x: x, y: y)
    }

    //=============================
    // Public Stored Properties
    //=============================

    public var items: [BTabViewItem] = []

    public init(_ parent: BView) {
        super.init(parent: parent, geometry: Rect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))

        self.size = Size(width: 100.0, height: 100.0)
        // self.layout = FillLayout()
        // self.layout?.insets = Insets(all: 12.0)

        _frameView = Frame(parent: self)

        _itemView = BView(parent: _frameView, geometry: self._itemViewGeometry)
        _itemView.color = .transparent
        _itemView.layout = FillLayout()

        _tabButtons = TabButtonGroup()
        _tabButtons.parent = self

        // _frameView.setTabButtonGroup(_tabButtons)
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
        // _tabButtons.size.width = event.size.width
        // _itemView.geometry = _itemViewGeometry

        // self.layingOut()
        _frameView.geometry = _frameGeometry
        _tabButtons.position = _tabButtonGroupPosition

        super.resizeEvent(event)
    }
}
