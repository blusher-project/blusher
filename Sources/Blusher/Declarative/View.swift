internal protocol _TupleView {
    func getViews() -> [any View]
}

public struct TupleView<T>: View {
    public var value: T

    public var body: some View {
        EmptyView()
    }

    public init(_ value: T) {
        self.value = value
    }
}

extension TupleView: _TupleView {
    func getViews() -> [any View] {
        let mirror = Mirror(reflecting: self.value)
        return mirror.children.compactMap { $0.value as? any View }
    }
}

extension Never: View {
    public typealias Body = Never

    public var body: Never {
        fatalError("Never body.")
    }
}

public struct EmptyView: View {
    public typealias Body = Never

    public var body: Never {
        fatalError("EmptyView has no body")
    }

    public init() {
    }
}

@resultBuilder
public struct ViewBuilder {
    public static func buildBlock() -> EmptyView {
        EmptyView()
    }

    public static func buildBlock<Content>(_ content: Content) -> Content where Content : View {
        content
    }

    public static func buildBlock<C0: View, C1: View>(_ c0: C0, _ c1: C1) -> TupleView<(C0, C1)> {
        TupleView((c0, c1))
    }

    public static func buildBlock<C0: View, C1: View, C2: View>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleView<(C0, C1, C2)> {
        TupleView((c0, c1, c2))
    }

    public static func buildBlock<C0: View, C1: View, C2: View, C3: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) -> TupleView<(C0, C1, C2, C3)> {
        TupleView((c0, c1, c2, c3))
    }

    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> TupleView<(C0, C1, C2, C3, C4)> {
        TupleView((c0, c1, c2, c3, c4))
    }
}

public protocol View: Visible {
    associatedtype Body : View

    @ViewBuilder
    var body: Body { get }
}

//===============
// Modifiers
//===============

extension View {
    public func radius(_ radius: Radius) -> some View {
        self.modifier { store in
            store[RadiusKey.self] = radius
        }
    }
}

extension View {
    public func filters(_ filters: [Filter]) -> some View {
        self.modifier { store in
            store[FiltersKey.self] = filters
        }
    }
}

extension View {
    public func cursorShape(_ cursorShape: CursorShape) -> some View {
        self.modifier { store in
            store[CursorShapeKey.self] = cursorShape
        }
    }
}

//==============
// Renderer
//==============

class ViewRenderer {
    var uiSurface: BSurface
    var rootView: any View
    var stateBounded: Bool = false

    init(uiSurface: BSurface, view: any View) {
        self.uiSurface = uiSurface
        self.rootView = view
    }

    func visit(
        view: any View,
        store: PropertyStore,
        parentViewHandle: BView?,
        action: (any View, PropertyStore, BView?) -> BView
    ) -> BView? {
        var store = store

        // print(" - Visiting: \(type(of: view))")
        //
        if !stateBounded {
            let mirror = Mirror(reflecting: view)
            for child in mirror.children {
                if let state = child.value as? _State {
                    state.setOnChange {
                        self.updateHandler()
                    }
                }
            }
        }

        // Process layouts.
        if let layout = view as? any Declarative.Layout {
            // Layout itself.
            let viewHandle = visit(
                view: layout.selfContent,
                store: store,
                parentViewHandle: parentViewHandle,
                action: action
            )
            /* TODO!: Implementation!!!
            viewHandle?.layoutConstraint = LayoutConstraint(
                rootNode: viewHandle!,
                childNodes: [],
                constraintFunction: layout.constraintFunction
            )
            */

            // Layout children.
            if let children = layout.childrenContent as? _TupleView {
                for iter in children.getViews() {
                    let viewHandleChild = visit(
                        view: iter,
                        store: store,
                        parentViewHandle: viewHandle!,
                        action: action
                    )
                    viewHandle?.layoutConstraint?.childNodes.append(viewHandleChild!)
                }
            }
            viewHandle?.layingOut()

            return viewHandle
        }

        // Process children views.
        if let childrenModifier: any _ChildrenModifiedView = view as? _ChildrenModifiedView {
            let viewHandle = visit(
                view: childrenModifier.innerContent,
                store: store,
                parentViewHandle: parentViewHandle,
                action: action
            )

            let _ = visit(
                view: childrenModifier.childrenContent,
                store: store,
                parentViewHandle: viewHandle,
                action: action
            )

            return viewHandle
        }

        // Process modified view.
        if let modifier = view as? _PropertyModifiedView {
            modifier.apply(&store)

            return visit(
                view: modifier.innerContent,
                store: store,
                parentViewHandle: parentViewHandle,
                action: action
            )
        }

        // Process tuple view.
        if let tupleView = view as? _TupleView {
            for iter in tupleView.getViews() {
                let _ = visit(
                    view: (iter is _PropertyModifiedView) ? iter : iter,
                    store: store,
                    parentViewHandle: parentViewHandle,
                    action: action
                )
            }
        } else if view.body is EmptyView {
            return action(view, store, parentViewHandle)
        } else {
            return visit(view: view.body, store: store, parentViewHandle: parentViewHandle, action: action)
        }

        return parentViewHandle
    }

    func render(view: any View, store: PropertyStore, parentViewHandle: BView?) {
        print(" - ViewRenderer.render()")
        let _ = visit(view: view, store: store, parentViewHandle: parentViewHandle) { view, store, parent in
            let viewHandle = parent == nil
                ? BView(
                    surface: self.uiSurface,
                    geometry: store[GeometryKey.self]
                )
                : BView(parent: parent!, geometry: store[GeometryKey.self])

            // Basic appearance.
            viewHandle.geometry = store[GeometryKey.self]
            viewHandle.color = store[ColorKey.self]
            viewHandle.radius = store[RadiusKey.self]
            viewHandle.cursorShape = store[CursorShapeKey.self]
            // Filters.
            for filter in store[FiltersKey.self] {
                viewHandle.addFilter(filter)
            }
            // Image.
            if let imageView = view as? Image {
                viewHandle.renderType = .image
                if viewHandle.image == nil {
                    let file = FileSystem.File.open(imageView.path!, "rb")
                    viewHandle.image = ImageHandle(from: file.readAll())
                    file.close()
                }
            }
            // Events.
            bindHandler(for: PointerEnterKey.self, in: store, to: &viewHandle._pointerEnterHandler)
            bindHandler(for: PointerLeaveKey.self, in: store, to: &viewHandle._pointerLeaveHandler)
            bindHandler(for: PointerMoveKey.self, in: store, to: &viewHandle._pointerMoveHandler)
            bindHandler(for: PointerPressKey.self, in: store, to: &viewHandle._pointerPressHandler)
            bindHandler(for: PointerReleaseKey.self, in: store, to: &viewHandle._pointerReleaseHandler)
            bindHandler(for: PointerClickKey.self, in: store, to: &viewHandle._pointerClickHandler)

            return viewHandle
        }
    }

    func update(view: any View, store: PropertyStore, parentViewHandle: BView?) {
        print(" - ViewRenderer.update()")
        var index = 0
        let _ = visit(view: view, store: store, parentViewHandle: parentViewHandle) { view, store, parent in
            let viewHandle = uiSurface.children[index]

            viewHandle.geometry = store[GeometryKey.self]
            viewHandle.color = store[ColorKey.self]

            index += 1

            return viewHandle
        }
    }

    func updateHandler() {
        update(view: self.rootView, store: PropertyStore(), parentViewHandle: nil)
    }

    /// A helper function for bind event handlers.
    private func bindHandler<K: PropertyKey>(
        for key: K.Type,
        in store: PropertyStore,
        to target: inout K.Value
    ) {
        target = store[key]
    }
}
