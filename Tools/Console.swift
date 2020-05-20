import Foundation

public func printSuccess(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    let fileName = file.components(separatedBy: "/").last ?? "unknown file"
    print("✅ Success: \(message)\n at \(function) in \(fileName):\(line)")
    #endif
}
public func printError(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    let fileName = file.components(separatedBy: "/").last ?? "unknown file"
    print("❌ Error: \(message)\n at \(function) in \(fileName):\(line)")
    #endif
}
public func printInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    let fileName = file.components(separatedBy: "/").last ?? "unknown file"
    print("👀 Info: \(message)\n at \(function) in \(fileName):\(line)")
    #endif
}
