# 队列

队列（queue），是先进先出（FIFO, First-In-First-Out）的线性表。

> FIFO 表明队列中的任务按照加入的顺序依次被取出，但并不表示它们不能同时执行。例如并发队列。

根据队列的特性我们可以抽象出一个协议来描述它：

```swift
protocol Queue {
    associatedtype Element
    /// 队列中元素个数
    var count: Int { get }
    /// 检查是否为空队列
    var isEmpty: Bool { get }
    /// 返回最前面的元素而不让其出队
    var peek: Element? { get }
    /// 入队
    mutating func enquque(element: Element)
    /// 出队
    mutating func dequeue() -> Element?
}
```

队列的实现方式有多种，下面我们将使用数组来实现一个简单队列。

```swift
struct QueueWithArray<T>: Queue {
    
    typealias Element = T
    
    private var array: [T] = []
    
    var count: Int {
        return array.count
    }
    
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

这个队列可以正常工作，但是我们还需要考虑其执行效率。

在这个队列中，入队操作的时间复杂度是 O(1)。

> 你可能会问为什么向数组尾部添加元素是一个常数时间复杂度呢？这是因为 Swift 中的数组尾部总会预留一些空间。
>
> ```swift
> [ "Ada", "Steve", "Tim", xxx, xxx, xxx ]
> ```
> 当预留空间全部被赋值且又有新的元素即将加入数组时，才会进行扩容操作。
> 
> 扩容时会申请新的内存空间，并将当前数组中的所有元素复制到新的数组中。所以扩容操作的时间复杂度是 O(n)，但由于扩容操作是偶尔才会发生，所以我们可以近似地认为向 Swift 数组尾部添加元素是一个 O(1) 的操作。

出队操作的复杂度是 O(n) 。

> 这是因为在进行出队操作时，需要先把数组头部的元素移除，然后所有元素向前移动一个位置。
> 
> ```
> before   [ "Ada", "Steve", "Tim", "Grace", xxx, xxx ]
                   /       /      /
                  /       /      /
                 /       /      /
                /       /      /
 after   [ "Steve", "Tim", "Grace", xxx, xxx, xxx ]
> ```

为了让队列更高效，我们需要对出队操作进行一些调整：在出队方法被调用的时候，我们先不对数组中的第一个元素进行移除操作，而是把她标记为空。

例如将 “Ada” 出队之后，队列中的数组元素实际上变成了：

```swift
[ xxx, "Steve", "Tim", "Grace", xxx, xxx ]
```
由于数组中的这些空元素不能被重复利用，所以我们需要在合适的时机对数组进行修剪，比如数组长度大于50，且前 25%的位置被标记为空。

```swift
struct QueueArray<T>: Queue {
    typealias Element = T
    
    private var array: [T?] = []
    private var head: Int = 0
    
    var count: Int {
        return array.count - head
    }
    
    var isEmpty: Bool {
        return count == 0
    }
    
    var peek: T? {
        return array[head]
    }
    
    mutating func enquque(element: T) {
        array.append(element)
    }
    
    mutating func dequeue() -> T? {
        guard head < array.count, let element = array[head] else { return nil }
        array[head] = nil
        head += 1

        let percentage = Double(head)/Double(array.count)
        if array.count > 50 && percentage > 0.25 {
          array.removeFirst(head)
          head = 0
        }
        
        return element
    }
}
```
经过优化之后，对数组的修剪操作偶尔发生，因此可以将出队操作近似地看做 O(1) 复杂度。
至此，我们创建了一个入队出队操作都是 O(1) 的队列。

当然，我们也可以通过合理地设计，构建一种高效重用数组的队列，比如下面的循环队列。

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

- [https://github.com/raywenderlich/swift-algorithm-club/tree/master/Queue](https://github.com/raywenderlich/swift-algorithm-club/tree/master/Queue)
- [Swift: Queue Data Structure](https://medium.com/@FOBmemory/swift-queue-data-structure-b9c9734f3462)