public enum MenuItemType {
    case menu
    case item
    case separator
}

public struct MenuItem {
    private var _type: MenuItemType
    private var _title: String = ""
    private var _menu: Menu? = nil

    public var menu: Menu? {
        _menu
    }

    public var title: String {
        get { _title }
        set { _title = newValue }
    }

    public init(_ type: MenuItemType) {
        _type = type
        if type == .menu {
            _menu = Menu()
        }
    }
}

public struct Menu {
    private var _items: [MenuItem] = []

    public var items: [MenuItem] {
        _items
    }

    public static var commonMenuBarMenu: Menu {
        var menu = Menu()

        // File.
        var fileMenu = MenuItem(.menu)
        fileMenu.title = "File"

        // Edit.
        var editMenu = MenuItem(.menu)
        editMenu.title = "Edit"

        // Add all.
        menu.addItem(fileMenu)
        menu.addItem(editMenu)

        return menu
    }

    public init() {
    }

    public mutating func addItem(_ item: MenuItem) {
        _items.append(item)
    }
}
