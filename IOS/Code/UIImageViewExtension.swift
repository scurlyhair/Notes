import UIKit

extension UIImageView {
    /// 异步加载图片的最大并发数
    private static let load_semaphore: DispatchSemaphore = DispatchSemaphore(value: 5)

    /// 从 url 异步加载图片
    /// - Parameters:
    ///   - url: 图片 url
    ///   - placeholder: 默认图片
    ///   - queue: 图片加载的队列
    func load(url: String, placeholder: UIImage? = nil, onFailed: ((_ error: Error) -> ())? = nil) {
        image = placeholder

        guard let urlStr = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlStr) else {
            print("Error: invalid image url")
            return
        }
        var imgData: Data?

        let download = DispatchWorkItem {
            Self.load_semaphore.wait()
            defer {
                Self.load_semaphore.signal()
            }

            let result = URLSession.shared.synchronousDataTask(with: url)
            if let error = result.2 {
                if let onFailed = onFailed {
                    onFailed(error)
                }
                return
            }
            imgData = result.0
        }

        let load = DispatchWorkItem(qos: .userInteractive) { [weak self] in
            guard let data = imgData else { return }
            let img = UIImage(data: data)
            self?.image = img
        }
        download.notify(queue: .main, execute: load)

        let queue = DispatchQueue(label: "image_load_queue", qos: .utility, attributes: [.concurrent])
        queue.async(execute: download)
    }
}

private extension URLSession {
    /// 同步请求
    func synchronousDataTask(with url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: url) {
            data = $0
            response = $1
            error = $2

            semaphore.signal()
        }
        dataTask.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return (data, response, error)
    }
}
