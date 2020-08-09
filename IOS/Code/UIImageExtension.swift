import UIKit

extension UIImage {
    /// 在图片上写入文字
    /// - Parameters:
    ///   - text: 待写入文本
    ///   - attrs: 文本属性
    ///   - point: 文本在图片上的起点位置
    /// - Returns: 成功写入文本的图片
    func textToImage(drawText text: String, withAttributes attrs: [NSAttributedString.Key: Any]? = nil, atPoint point: CGPoint) -> UIImage {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)

        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))

        let rect = CGRect(origin: point, size: self.size)
        text.draw(in: rect, withAttributes: attrs)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
