
extension String {
    // 获取 a~z 小写英文字母集合
    static func getLowercaseLetters() -> [String] {
        let aScalars = "a".unicodeScalars
        let aCode = aScalars[aScalars.startIndex].value
        let letters: [String] = (0..<26).map { String(UnicodeScalar(aCode + $0)!) }
        return letters
    }
    // 获取 A~Z 大写英文字母集合
    static func getCapitalLetters() -> [String] {
        let aScalars = "A".unicodeScalars
        let aCode = aScalars[aScalars.startIndex].value
        let letters: [String] = (0..<26).map { String(UnicodeScalar(aCode + $0)!) }
        return letters
    }
    // 获取 0~9 数字集合
    static func getNumbers() -> [String] {
        let zeroScalars = "0".unicodeScalars
        let zeroCode = zeroScalars[zeroScalars.startIndex].value
        let numbers: [String] = (0..<10).map { String(UnicodeScalar(zeroCode + $0)!) }
        return numbers
    }
}
