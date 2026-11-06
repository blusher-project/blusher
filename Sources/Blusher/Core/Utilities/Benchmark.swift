public class Benchmark {
    private let string: String
    private let startTime: ContinuousClock.Instant

    init(_ string: String) {
        self.string = string
        self.startTime = .now
    }

    deinit {
    }

    public func end() {
        let duration = startTime.duration(to: .now)
        print("[\(string)] \(duration)")
    }
}
