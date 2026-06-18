@_silgen_name("write")
func write(_: Int32, _: UnsafeRawPointer, _: Int) -> Int

@_silgen_name("isatty")
func isatty(_: Int32) -> Int32

internal final class Logger: Sendable {
    public enum LogLevel {
        case debug
        case warning
        case error
    }

    private enum ANSIColor: String {
        case reset = "\u{1B}[0m"
        case green = "\u{1B}[1;32m"
        case yellow = "\u{1B}[1;33m"
        case red = "\u{1B}[1;31m"
        case gray = "\u{1B}[90m"
    }

    private static let shared: Logger = Logger()

    private init() {
        //
    }

    public static func log(_ level: LogLevel, _ message: String, _ function: String = #function) {
        let fd: Int32 = level == .debug ? 1 : 2
        let color: ANSIColor = switch level {
        case .debug: .green
        case .warning: .yellow
        case .error: .red
        }
        let levelString = switch level {
        case .debug: "\(color.rawValue)[DEBUG]\(ANSIColor.reset.rawValue)"
        case .warning: "\(color.rawValue)[WARN]\(ANSIColor.reset.rawValue)"
        case .error: "\(color.rawValue)[ERROR]\(ANSIColor.reset.rawValue)"
        }
        let funcString = "\(ANSIColor.gray.rawValue)\(function)\(ANSIColor.reset.rawValue)"
        var msg = "Blusher \(levelString) \(funcString) \(message)\n"
        let _ = msg.withUTF8 { ptr in
            write(fd, ptr.baseAddress!, ptr.count)
        }
    }

    public static func debug(_ message: String, _ function: String = #function) {
        Self.log(.debug, message, function)
    }

    public static func warn(_ message: String, _ function: String = #function) {
        Self.log(.warning, message, function)
    }

    public static func error(_ message: String, _ function: String = #function) {
        Self.log(.error, message, function)
    }
}
