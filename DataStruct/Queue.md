# 队列

队列（queue），是先进先出（FIFO, First-In-First-Out）的线性表。

> FIFO 表明队列中的任务按照加入的顺序依次被取出，但并不表示它们不能同时执行。例如并发队列。

根据队列的特性我们可以抽象出一个协议来描述它：

```swift
protocol Queue {
    associatedtype Element
    /// 入队
    mutating func enquque(element: Element)
    /// 出队
    mutating func dequeue() -> Element?
    /// 检查是否为空队列
    var isEmpty: Bool { get }
    /// 返回最前面的元素而不让其出队
    var peek: Element? { get }
}
```


队列可以通过其他的数据结构来实现，下面使用数组来实现一个简单的队列：

```swift
struct QueueWithArray<T>: Queue {
    private var array: Array<T> = []
    
    typealias Element = T
    
    var isEmpty: Bool {
        return array.isEmpty
    }
    
    var peek: T? {
        return array.first
    }
    
    mutating func enquque(element: T) {
        array.append(element)
    }
    
    mutating func dequeue() -> T? {
        if array.isEmpty { return nil }
        return array.removeFirst()
    }
}
```

如果注意的话，我们可以发现，上面的队列并没有长度限制。这就意味着我们可以无限制地进行入队操作，这个在程序设计中并不是一个的方案。

我们可以对其做一些改进，在它的构造方法中设置列长度的最大值。


### 循环队列

```swift
import Foundation

class CircularQueue {

    private var array: [Int?]
    private var size: Int
    private var head: Int
    private var tail: Int
    
    /** Initialize your data structure here. Set the size of the queue to be k. */
    init(_ k: Int) {
        array = Array(repeating: nil, count: k)
        size = k
        head = -1
        tail = -1
    }
    
    /** Insert an element into the circular queue. Return true if the operation is successful. */
    func enQueue(_ value: Int) -> Bool {
        if isFull() {
            return false
        }
        if isEmpty() {
            head += 1
        }
        tail += 1
        tail %= size
        array[tail] = value
        return true
    }
    
    /** Delete an element from the circular queue. Return true if the operation is successful. */
    func deQueue() -> Bool {
        if isEmpty() {
            return false
        }
        if head == tail {
            head = -1
            tail = -1
            return true
        }
        head += 1
        head %= size
        return true
    }
    
    /** Get the front item from the queue. */
    func Front() -> Int {
        if isEmpty() {
            return -1
        }
        return array[head]!
    }
    
    /** Get the last item from the queue. */
    func Rear() -> Int {
        if isEmpty() {
            return -1
        }
        return array[tail]!
    }
    
    /** Checks whether the circular queue is empty or not. */
    func isEmpty() -> Bool {
        return head == -1
    }
    
    /** Checks whether the circular queue is full or not. */
    func isFull() -> Bool {
        return (tail + 1)%size == head
    }
}
```

参考文档：

- [Swift: Queue Data Structure](https://medium.com/@FOBmemory/swift-queue-data-structure-b9c9734f3462)