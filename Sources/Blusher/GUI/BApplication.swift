@_implementationOnly import Swingby
@_implementationOnly import BlusherResources

public class BApplication {
    nonisolated(unsafe) public static var shared: BApplication!

    private var _sbApplication: OpaquePointer? = nil

    private var _nextTickEventListener: EventListener!

    internal var _nextTickHandler: ((Event) -> Void)? = nil

    public var rebuildReady: Bool = false

    public init(_ args: [String]) {
        let argc = Int32(args.count)
        let cArgs: [UnsafeMutablePointer<CChar>?] = args.map {
            $0.withCString { UnsafeMutablePointer(mutating: $0) }
        }

        cArgs.withUnsafeBufferPointer { buffer in
            let argv = UnsafeMutablePointer(mutating: buffer.baseAddress)
            let result = sb_application_new(argc, argv)
            _sbApplication = result
        }

        // Register resources.
        for resource in BlusherResources.getResources() {
            let addr = resource.address
            let size = resource.size
            let name = resource.name
            let resource = Resource(name, Bytes(fromStatic: addr, size: size))
            self.registerResource(resource)
        }

        addEventListeners()

        BApplication.shared = self
    }

    public func registerResource(_ resource: Resource) {
        ResourceManager.shared.register(resource)
    }

    public func addTimer(to surface: BSurface, interval: Int, repeats: Bool) -> Int {
        let id = sb_application_add_timer(_sbApplication,
            surface.sbSurface, UInt32(interval), repeats)

        return Int(id)
        // TODO: Wrap ID as struct TimerID.
    }

    public func removeTimer(for id: Int) {
        sb_application_remove_timer(_sbApplication, UInt32(id))
    }

    public func exec() -> Int {
        return Int(sb_application_exec(_sbApplication))
    }

    private func addEventListeners() {
        let userData = Unmanaged.passUnretained(self).toOpaque()

        // Next tick event.
        _nextTickEventListener = { sbEvent, userData in
            if let userData = userData {
                let instance = Unmanaged<BApplication>.fromOpaque(userData).takeUnretainedValue()

                instance.callNextTickEvent(sbEvent)
            }
        } as EventListener
        sb_application_add_event_listener(_sbApplication,
            SB_EVENT_TYPE_NEXT_TICK,
            _nextTickEventListener,
            userData
        )
    }

    private func callNextTickEvent(_ sbEvent: UnsafeMutablePointer<sb_event_t>?) {
        let event = Event(of: .nextTick)
        nextTickEvent(event)
    }

    open func nextTickEvent(_ event: Event) {
        rebuildReady = true
        _nextTickHandler?(event)
    }
}
