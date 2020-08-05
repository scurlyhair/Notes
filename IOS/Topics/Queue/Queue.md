# 队列

```swift
class Demo {
    var text: String {
        get {
            print("read - \(Thread.current)")
            return ""
        }
        set {
            print("write - \(Thread.current)")
        }
    }
}

let demo = Demo()

// 并发队列
let queue = DispatchQueue.init(label: "concurrent_quque", qos: .default, attributes: [.concurrent], autoreleaseFrequency: .inherit, target: nil)

let writeWork1 = DispatchWorkItem.init(qos: .default, flags: .barrier) {
    // 写操作
    for i in 0..<3 {
        sleep(1)
        demo.text = "\(i)"
    }
}
let writeWork2 = DispatchWorkItem.init(qos: .default, flags: .inheritQoS) {
    // 写操作
    for i in 0..<3 {
        sleep(1)
        demo.text = "\(i)"
    }
}

let readWork1 = DispatchWorkItem.init {
    // 读操作
    for _ in 0..<3 {
        sleep(1)
        let _ = demo.text
    }
}
let readWork2 = DispatchWorkItem.init {
    // 读操作
    for _ in 0..<3 {
        sleep(1)
        let _ = demo.text
    }
}

queue.async(execute: readWork1)
queue.async(execute: readWork2)
queue.async(execute: writeWork1)
queue.async(execute: writeWork2)
```