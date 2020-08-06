# GCD探索

## 概览

**串行、并发、并行：**

串行：处理器 A 依次处理 a、b、c 三个任务。

并发：处理器 A 同时处理 a、b、c 三个任务。

并行：处理器 A、B、C 同时分别处理 a、b、c 三个任务。

**同步、异步**

同步： 处理器 A 处理 a 任务并保持等待，直到返回结果之后再去处理 b 事件......

异步：处理器 A 同时处理 a 任务的同时，开始处理 b 任务，某个任务执行完之后会以通知、回调等方式告诉处理器。

> 在 GCD 中同步执行不会创建新线程，而异步执行会创建尽可能多的线程。

**接下来需要为后面的探索做一些准备：**

```swift
import Foundation

class Demo {
    private var value: String?
}

// MARK: - 属性、队列、操作

extension Demo {
    /// 被读写属性
    private var text: String? {
        get {
            print("will read", value ?? "x", CFAbsoluteTimeGetCurrent(), Thread.current, separator: " - ")
            return value
        }
        set {
            print("will write", newValue ?? "x", CFAbsoluteTimeGetCurrent(), Thread.current, separator: " - ")
            value = newValue
        }
    }

    /// 串行队列
    private func constructSerialQueue() -> DispatchQueue {
        return DispatchQueue(label: "serial_queue_\(CFAbsoluteTimeGetCurrent())")
    }

    /// 并发队列
    private func constructConcurrentQueue() -> DispatchQueue {
        return DispatchQueue(label: "concurrent_queue_\(CFAbsoluteTimeGetCurrent())", qos: .default, attributes: [.concurrent], autoreleaseFrequency: .inherit, target: nil)
    }

    /// 读操作
    private func constructReadWork() -> DispatchWorkItem {
        return DispatchWorkItem {
            for _ in 0..<3 {
                _ = self.text
                sleep(1)
            }
        }
    }

    /// 写操作
    private func constructWriteWork() -> DispatchWorkItem {
        return DispatchWorkItem {
            for i in 0..<3 {
                sleep(1)
                self.text = "\(i)"
            }
        }
    }

    /// 写操作 - 阻塞方式
    private func constructBarrierWriteWork() -> DispatchWorkItem {
        return DispatchWorkItem(qos: .default, flags: .barrier) {
            for i in 0..<3 {
                sleep(1)
                self.text = "\(i)"
            }
        }
    }
}
```

## 串行队列

串行队列中的任务会按照入队顺序依次执行。

### 串行同步

串行同步不会创建新的线程，而是再当前线程中依次执行任务。

```swift
extension Demo {
    /// 串行同步
    func serialSyncTest() {
        let serialQueue = constructSerialQueue()
        let readWork = constructReadWork()
        let writeWork = constructWriteWork()

        serialQueue.sync {
            readWork.perform()
            writeWork.perform()
        }
    }
}

Demo().serialSyncTest()

/**
 will read - x - 618386266.083965 - <NSThread: 0x6000033342c0>{number = 1, name = main}
 will read - x - 618386267.099724 - <NSThread: 0x6000033342c0>{number = 1, name = main}
 will read - x - 618386268.100578 - <NSThread: 0x6000033342c0>{number = 1, name = main}
 will write - 0 - 618386270.10238 - <NSThread: 0x6000033342c0>{number = 1, name = main}
 will write - 1 - 618386271.105043 - <NSThread: 0x6000033342c0>{number = 1, name = main}
 will write - 2 - 618386272.106632 - <NSThread: 0x6000033342c0>{number = 1, name = main}
 */
```

### 串行异步

串行异步会创建一个新的线程并在新线程中依次执行任务。

```swift
extension Demo {
    /// 串行异步
    func serialAsyncTest() {
        let serialQueue = constructSerialQueue()
        let readWork = constructReadWork()
        let writeWork = constructWriteWork()

        serialQueue.async {
            readWork.perform()
            writeWork.perform()
        }
    }
}

Demo().serialAsyncTest()

/**
 will read - x - 618386412.410786 - <NSThread: 0x6000033eec00>{number = 4, name = (null)}
 will read - x - 618386413.438499 - <NSThread: 0x6000033eec00>{number = 4, name = (null)}
 will read - x - 618386414.442569 - <NSThread: 0x6000033eec00>{number = 4, name = (null)}
 will write - 0 - 618386416.452602 - <NSThread: 0x6000033eec00>{number = 4, name = (null)}
 will write - 1 - 618386417.455897 - <NSThread: 0x6000033eec00>{number = 4, name = (null)}
 will write - 2 - 618386418.461323 - <NSThread: 0x6000033eec00>{number = 4, name = (null)}
 */
```