# GCD 中的串行并行、同步异步

## 概览

**串行、并发、并行：**

串行：处理器 A 依次处理 a、b、c 三个任务。

并发：处理器 A 同时处理 a、b、c 三个任务。

并行：处理器 A、B、C 同时分别处理 a、b、c 三个任务。

**同步、异步**

同步： 处理器 A 处理 a 任务并保持等待，直到返回结果之后再去处理 b 事件......

异步：处理器 A 同时处理 a 任务的同时，开始处理 b 任务，某个任务执行完之后会以通知、回调等方式告诉处理器。

> 在 GCD 中同步执行不会创建新线程，而异步执行会为每**个 async 代码块** 创建一个新线程，可以使用信号量来控制最大并发量。

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

串行同步不会创建新的线程，而是在当前线程中依次执行任务。

```swift
extension Demo {
    /// 串行同步
    func serialSyncTest() {
        let serialQueue = constructSerialQueue()
        let readWork = constructReadWork()
        let writeWork = constructWriteWork()

        serialQueue.sync(execute: readWork)
        serialQueue.sync(execute: writeWork)
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

        serialQueue.async(execute: readWork)
        serialQueue.async(execute: writeWork)
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

## 并发队列

### 并发同步

并发同步会在当前线程依次执行任务。

```swift
// MARK: - 并发同步

extension Demo {
    func concurrentSyncTest() {
        let concurrentQueue = constructConcurrentQueue()
        let read = constructReadWork()
        let write = constructWriteWork()
        concurrentQueue.sync(execute: read)
        concurrentQueue.sync(execute: write)
    }
}

Demo().concurrentSyncTest()

/**
 will read - x - 618388814.845383 - <NSThread: 0x60000346c300>{number = 1, name = main}
 will read - x - 618388815.848179 - <NSThread: 0x60000346c300>{number = 1, name = main}
 will read - x - 618388816.848945 - <NSThread: 0x60000346c300>{number = 1, name = main}
 will write - 0 - 618388818.852131 - <NSThread: 0x60000346c300>{number = 1, name = main}
 will write - 1 - 618388819.854925 - <NSThread: 0x60000346c300>{number = 1, name = main}
 will write - 2 - 618388820.85593 - <NSThread: 0x60000346c300>{number = 1, name = main}
 */
```

### 并发异步

并发异步，会为每个 **async 代码块** 创建一个新的线程，多个线程同时处理其中的任务。

```swift
// MARK: - 并发异步

extension Demo {
    func concurrentAsyncTest() {
        let concurrentQueue = constructConcurrentQueue()
        let read = constructReadWork()
        let write = constructWriteWork()

        concurrentQueue.async(execute: read)
        concurrentQueue.async(execute: write)
    }
}

 Demo().concurrentAsyncTest()

/**
will read - x - 618389654.216249 - <NSThread: 0x600000524d40>{number = 6, name = (null)}
will write - 0 - 618389655.219599 - <NSThread: 0x60000053f380>{number = 4, name = (null)}
will read - 0 - 618389655.244974 - <NSThread: 0x600000524d40>{number = 6, name = (null)}
will write - 1 - 618389656.221945 - <NSThread: 0x60000053f380>{number = 4, name = (null)}
will read - 1 - 618389656.246116 - <NSThread: 0x600000524d40>{number = 6, name = (null)}
will write - 2 - 618389657.22687 - <NSThread: 0x60000053f380>{number = 4, name = (null)}
*/
```

如果使用以下方式调用，则只会创建一个新线程：

```swift
concurrentQueue.async {
    read.perform()
    write.perform()
}

/**
 will read - x - 618389059.343989 - <NSThread: 0x600002043f80>{number = 5, name = (null)}
 will read - x - 618389060.385459 - <NSThread: 0x600002043f80>{number = 5, name = (null)}
 will read - x - 618389061.38772 - <NSThread: 0x600002043f80>{number = 5, name = (null)}
 will write - 0 - 618389063.391281 - <NSThread: 0x600002043f80>{number = 5, name = (null)}
 will write - 1 - 618389064.396294 - <NSThread: 0x600002043f80>{number = 5, name = (null)}
 will write - 2 - 618389065.399167 - <NSThread: 0x600002043f80>{number = 5, name = (null)}
 */
```

### 并发异步中的最大并发数控制

由于在**并发异步**模式中，GCD 会尽可能地为每个 async 代码块 开辟新线程，而系统支持的最大线程总数并不是无限的，因此在大规模并发场景下，就需要控制最大并发数量。可以使用信号量 `Semaphore` 来实现。

> MacBook Pro (Retina, 13-inch, Early 2015) 10.15.5 系统下 xcodePlayerground 支持创建的最大线程总数是 69 左右。

设置最大并发数为 3：

```swift
// MARK: - 最大并发数

extension Demo {
    func maxConcurrentTest() {
        let semaphore = DispatchSemaphore(value: 2)
        let queue = constructConcurrentQueue()

        for _ in 0..<30 {
            let read = constructReadWork()
            queue.async {
                read.perform()
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
}

Demo().maxConcurrentTest()

/**
 will read - x - 618391274.140428 - <NSThread: 0x6000031e4100>{number = 4, name = (null)}
 will read - x - 618391274.140996 - <NSThread: 0x6000031e11c0>{number = 8, name = (null)}
 will read - x - 618391274.14058 - <NSThread: 0x6000031e4fc0>{number = 5, name = (null)}
 
 will read - x - 618391275.159634 - <NSThread: 0x6000031e11c0>{number = 8, name = (null)}
 will read - x - 618391275.159651 - <NSThread: 0x6000031e4100>{number = 4, name = (null)}
 will read - x - 618391275.159634 - <NSThread: 0x6000031e4fc0>{number = 5, name = (null)}
 
 will read - x - 618391276.163541 - <NSThread: 0x6000031e4100>{number = 4, name = (null)}
 will read - x - 618391276.163541 - <NSThread: 0x6000031e4fc0>{number = 5, name = (null)}
 */
```


### 并发异步中的阻塞操作

在定义 DispatchWorkItem 时，如果声明其 flags 为 `.barrier` 时，会阻塞队列使：

- 在其之前入队的 workItem 全部都执行完之后才开始执行当前 workItem
- 在其之后入队的 workItem 需要等待当前 workItem 执行完成之后才可以执行

```swift
// MARK: - 并发异步中的阻塞操作

extension Demo {
    func barrierConcurrentTest() {
        let queue = constructConcurrentQueue()
        let read = constructReadWork()
        let read2 = constructReadWork()
        let read3 = constructReadWork()
        let barrierWrite = constructBarrierWriteWork()
        queue.async(execute: read)
        queue.async(execute: barrierWrite)
        queue.async(execute: read2)
        queue.async(execute: read3)
    }
}

Demo().barrierConcurrentTest()

/**
 will read - x - 618392281.674938 - <NSThread: 0x60000323de40>{number = 4, name = (null)}
 will read - x - 618392282.70385 - <NSThread: 0x60000323de40>{number = 4, name = (null)}
 will read - x - 618392283.704647 - <NSThread: 0x60000323de40>{number = 4, name = (null)}
 
 will write - 0 - 618392285.712058 - <NSThread: 0x60000323de40>{number = 4, name = (null)}
 will write - 1 - 618392286.718607 - <NSThread: 0x60000323de40>{number = 4, name = (null)}
 will write - 2 - 618392287.721012 - <NSThread: 0x60000323de40>{number = 4, name = (null)}
 
 will read - 2 - 618392287.722343 - <NSThread: 0x60000323de40>{number = 4, name = (null)}
 will read - 2 - 618392287.722393 - <NSThread: 0x600003221e40>{number = 5, name = (null)}
 will read - 2 - 618392288.727694 - <NSThread: 0x60000323de40>{number = 4, name = (null)}
 will read - 2 - 618392288.72771 - <NSThread: 0x600003221e40>{number = 5, name = (null)}
 will read - 2 - 618392289.728766 - <NSThread: 0x60000323de40>{number = 4, name = (null)}
 will read - 2 - 618392289.728953 - <NSThread: 0x600003221e40>{number = 5, name = (null)}
 */
```


