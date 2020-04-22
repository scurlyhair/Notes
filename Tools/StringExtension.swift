
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
    
    /// 根据颜色编码生成 UIColor 实例
    func generateUIColor() -> UIColor {
        let leftParenCharset: CharacterSet = CharacterSet(charactersIn: "( ")
        let commaCharset: CharacterSet = CharacterSet(charactersIn: ", ")
        
        let colorString = self.lowercased()
        
        if colorString.hasPrefix("#")
        {
            var argb: [UInt] = [255, 0, 0, 0]
            let colorString = colorString.unicodeScalars
            var length = colorString.count
            var index = colorString.startIndex
            let endIndex = colorString.endIndex
            
            index = colorString.index(after: index)
            length = length - 1
            
            if length == 3 || length == 6 || length == 8
            {
                var i = length == 8 ? 0 : 1
                while index < endIndex
                {
                    var c = colorString[index]
                    index = colorString.index(after: index)
                    
                    var val = (c.value >= 0x61 && c.value <= 0x66) ? (c.value - 0x61 + 10) : c.value - 0x30
                    argb[i] = UInt(val) * 16
                    if length == 3
                    {
                        argb[i] = argb[i] + UInt(val)
                    }
                    else
                    {
                        c = colorString[index]
                        index = colorString.index(after: index)
                        
                        val = (c.value >= 0x61 && c.value <= 0x66) ? (c.value - 0x61 + 10) : c.value - 0x30
                        argb[i] = argb[i] + UInt(val)
                    }
                    
                    i += 1
                }
            }
            return UIColor(red: CGFloat(argb[1]) / 255.0, green: CGFloat(argb[2]) / 255.0, blue: CGFloat(argb[3]) / 255.0, alpha: CGFloat(argb[0]) / 255.0)
        }
        else if colorString.hasPrefix("rgba")
        {
            var a: Float = 1.0
            var r: Int32 = 0
            var g: Int32 = 0
            var b: Int32 = 0
            let scanner: Scanner = Scanner(string: colorString)
            scanner.scanString("rgba", into: nil)
            scanner.scanCharacters(from: leftParenCharset, into: nil)
            scanner.scanInt32(&r)
            scanner.scanCharacters(from: commaCharset, into: nil)
            scanner.scanInt32(&g)
            scanner.scanCharacters(from: commaCharset, into: nil)
            scanner.scanInt32(&b)
            scanner.scanCharacters(from: commaCharset, into: nil)
            scanner.scanFloat(&a)
            return UIColor(
                red: CGFloat(r) / 255.0,
                green: CGFloat(g) / 255.0,
                blue: CGFloat(b) / 255.0,
                alpha: CGFloat(a)
            )
        }
        else if colorString.hasPrefix("argb")
        {
            var a: Float = 1.0
            var r: Int32 = 0
            var g: Int32 = 0
            var b: Int32 = 0
            let scanner: Scanner = Scanner(string: colorString)
            scanner.scanString("argb", into: nil)
            scanner.scanCharacters(from: leftParenCharset, into: nil)
            scanner.scanFloat(&a)
            scanner.scanCharacters(from: commaCharset, into: nil)
            scanner.scanInt32(&r)
            scanner.scanCharacters(from: commaCharset, into: nil)
            scanner.scanInt32(&g)
            scanner.scanCharacters(from: commaCharset, into: nil)
            scanner.scanInt32(&b)
            return UIColor(
                red: CGFloat(r) / 255.0,
                green: CGFloat(g) / 255.0,
                blue: CGFloat(b) / 255.0,
                alpha: CGFloat(a)
            )
        }
        else if colorString.hasPrefix("rgb")
        {
            var r: Int32 = 0
            var g: Int32 = 0
            var b: Int32 = 0
            let scanner: Scanner = Scanner(string: colorString)
            scanner.scanString("rgb", into: nil)
            scanner.scanCharacters(from: leftParenCharset, into: nil)
            scanner.scanInt32(&r)
            scanner.scanCharacters(from: commaCharset, into: nil)
            scanner.scanInt32(&g)
            scanner.scanCharacters(from: commaCharset, into: nil)
            scanner.scanInt32(&b)
            return UIColor(
                red: CGFloat(r) / 255.0,
                green: CGFloat(g) / 255.0,
                blue: CGFloat(b) / 255.0,
                alpha: 1.0
            )
        }
        
        return UIColor.clear
    }
}
