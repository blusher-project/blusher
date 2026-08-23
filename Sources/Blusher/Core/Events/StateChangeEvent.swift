public class StateChangeEvent: Event {
    public var state: ToplevelState
    public var isOn: Bool
    public var size: SizeI

    public init(state: ToplevelState, on: Bool, _ size: SizeI) {
        self.state = state
        self.isOn = on
        self.size = size

        super.init(of: .stateChange)
    }
}
