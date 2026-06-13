@_implementationOnly import Swingby

public enum BlusherHelper {
    public static func timeNowMilliseconds() -> Int {
        return Int(sb_time_now_milliseconds())
    }
}
