import UIKit

// 验证码生成器
class CaptchaView: UIView {
    /// 验证是否正确
    public func checkCorrect(withInput text: String?) -> Bool {
        return code == text?.capitalized
    }
    
    // 验证码位数
    public var authCodeLength = 4
    // 验证码字体
    public var codeFont = UIFont.systemFont(ofSize: 40)
    // 验证码颜色
    public var codeColor: UIColor = .yellow
    // 干扰线颜色
    public var lineColor: UIColor = .lightGray
    // 干扰线宽度
    public var lineWidth: CGFloat = 3.0
    // 干扰线条数
    public var lineAmount: Int = 8
    
    // 正确的验证码
    private var code: String?
    
    // 验证码抽取池
    private var characters: [String] {
        get {
            // 获取 A~Z 英文字母集合
            let letters = String.getCapitalLetters()
            // 获取数字集合
            let numbers = String.getNumbers()
            // 剔除容易混淆的字符
            return (letters + numbers).filter{ !["0", "o", "1", "l", "I", "2", "z" ].contains($0) }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.gray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 捕捉点击事件 并重绘视图
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let point = touches.first?.location(in: self), self.point(inside: point, with: event) {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        code = getNewCode()
        
        // 绘制验证码
        let cSize = ("a" as NSString).size(withAttributes: [NSAttributedString.Key.font: codeFont])
        let width = rect.width/CGFloat(code!.count) - cSize.width
        let height = rect.height - cSize.height
        var cX: CGFloat, cY: CGFloat
        for i in 0..<code!.count {
            cX = CGFloat(arc4random()).truncatingRemainder(dividingBy: width) + rect.size.width/CGFloat(code!.count) * CGFloat(i)
            cY = CGFloat(arc4random()).truncatingRemainder(dividingBy: height)
            (String(Array(code!)[i]) as NSString).draw(at: CGPoint(x: cX, y: cY), withAttributes: [
                NSAttributedString.Key.font: codeFont,
                NSAttributedString.Key.foregroundColor: codeColor
            ])
        }
        
        // 绘制干扰线
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(lineWidth)
        var lX: CGFloat, lY: CGFloat
        for _ in 0..<lineAmount {
            context?.setStrokeColor(lineColor.cgColor)
            lX = CGFloat(arc4random()).truncatingRemainder(dividingBy: rect.size.width)
            lY = CGFloat(arc4random()).truncatingRemainder(dividingBy: rect.size.height)
            context?.move(to: CGPoint(x: lX, y: lY))
            lX = CGFloat(arc4random()).truncatingRemainder(dividingBy: rect.size.width)
            lY = CGFloat(arc4random()).truncatingRemainder(dividingBy: rect.size.height)
            context?.addLine(to: CGPoint(x: lX, y: lY))
            context?.strokePath()
        }
    }
    
    // 生成验证码
    private func getNewCode() -> String {
        var code = ""
        for _ in 0..<authCodeLength {
            code.append(characters[Int(arc4random())%characters.count])
        }
        return code
    }
}

extension String {
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
