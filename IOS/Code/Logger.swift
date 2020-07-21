import Foundation

enum Logger {
    case error(_ message: String)
    case success(_ message: String)
    case warning(_ message: String)
}

extension Logger {
    /// 打印信息
    func log() {
        #if DEBUG
        print(info)
        #endif
    }

    private var info: String {
        let location = "\(#function) in \(#file.components(separatedBy: "/").last ?? "unknown file"):\(#line)"
        switch self {
        case let .error(message):
            return "❌ Error: \(message)\n at \(location)"
        case let .success(message):
            return "✅ Success: \(message)\n at \(location)"
        case let .warning(message):
            return "⚠️ Warning: \(message)\n at \(location)"
        }
    }
}
