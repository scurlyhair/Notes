import Foundation

enum Logger {
    case error(_ message: String, function: String = #function, file: String = #file, line: Int = #line)
    case success(_ message: String, function: String = #function, file: String = #file, line: Int = #line)
    case warning(_ message: String, function: String = #function, file: String = #file, line: Int = #line)
}

extension Logger {
    /// 打印信息
    func log() {
        #if DEBUG
        print(info)
        #endif
    }

    private var info: String {
        switch self {
        case let .error(message, function, file, line):
            let location = "\(function) in \(file.components(separatedBy: "/").last ?? "unknown file"):\(line)"
            return "❌ Error: \(message)\n at \(location)"
        case let .success(message, function, file, line):
            let location = "\(function) in \(file.components(separatedBy: "/").last ?? "unknown file"):\(line)"
            return "✅ Success: \(message)\n at \(location)"
        case let .warning(message, function, file, line):
            let location = "\(function) in \(file.components(separatedBy: "/").last ?? "unknown file"):\(line)"
            return "⚠️ Warning: \(message)\n at \(location)"
        }
    }
}
