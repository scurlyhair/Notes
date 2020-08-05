import UIKit

extension UIImage {
    // 向 UIImage 添加文字
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
