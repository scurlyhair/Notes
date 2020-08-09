import UIKit

extension UIImageView {
    /// 从 url 异步加载图片
    /// - Parameters:
    ///   - url: 图片 url
    ///   - placeholder: 默认图片
    ///   - queue: 图片加载的队列
    func load(url: String, placeholder: UIImage? = nil, queue: DispatchQueue? = nil) {
        image = placeholder

        guard let urlStr = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlStr) else {
            print("Error: invalid image url")
            return
        }
        var imgData: Data?

        let download = DispatchWorkItem {
            let semaphore = DispatchSemaphore(value: 0)

            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    print(error.localizedDescription, "image url: \(url.absoluteString)")
                    return
                }
                imgData = data
                semaphore.signal()
            }.resume()
            semaphore.wait()
        }

        let load = DispatchWorkItem(qos: .userInteractive) {
            guard let data = imgData else { return }
            let img = UIImage(data: data)
            self.image = img
        }
        download.notify(queue: .main, execute: load)

        var imgQueue: DispatchQueue?
        if queue == nil {
            imgQueue = DispatchQueue(label: "img_download", qos: .utility)
        }
        imgQueue?.async(execute: download)
    }
}
