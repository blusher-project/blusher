@_implementationOnly import Swingby

public enum BlusherHelper {
    public static func timeNowMilliseconds() -> Int {
        return Int(sb_time_now_milliseconds())
    }

    public static func withBenchmark(_ message: String, _ function: (() -> Void)) {
        let clock = ContinuousClock()
        let begin = clock.now
        function()
        let end = clock.now
        let elapsed = begin.duration(to: end).components

        let ms = Int64(elapsed.seconds) * 1_000_000 + Int64(elapsed.attoseconds / 1_000_000_000_000)
        let sec = ms / 1_000_000
        let frac = ms % 1_000_000

        let fracStr = String(frac)
        let padded = String(repeating: "0", count: 6 - fracStr.count) + fracStr

        print("[\(sec).\(padded)] - \(message)")
    }
}
