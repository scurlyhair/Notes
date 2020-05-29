import Foundation

class Console {
    public static func logSuccess(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = file.components(separatedBy: "/").last ?? "unknown file"
        print("✅ Success: \(message)\n at \(function) in \(fileName):\(line)")
        #endif
    }
    public static func logError(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = file.components(separatedBy: "/").last ?? "unknown file"
        print("❌ Error: \(message)\n at \(function) in \(fileName):\(line)")
        #endif
    }
    public static func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = file.components(separatedBy: "/").last ?? "unknown file"
        print("👀 Info: \(message)\n at \(function) in \(fileName):\(line)")
        #endif
    }
}
