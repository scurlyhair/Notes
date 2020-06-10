# 优先队列

优先队列（Priority Queue）中每个元素都有自己的优先级。优先级最高的元素最先得到服务；优先级相同的元素按照其在优先队列中的顺序得到服务。

### 操作

优先队列至少需要支持下述操作：

- 插入带优先级的元素（insert_with_priority）
- 取出具有最高优先级的元素（pull_highest_priority_element）
- 查看最高优先级的元素（peek）：O(1) 时间复杂度

其它可选的操作：

- 检查优先级高的一批元素
- 清空优先队列
- 批插入一批元素
- 合并多个优先队列
- 调整一个元素的优先级

### 实现

优先队列的实现有多种方式：

- 有序数组：最重要的元素排在最后。不好的一点是插入操作很慢。因为需要对其后面的元素进行移位。
- 二叉查找树：可以用它来实现双端优先队列，因为它同时提供了最大值和最小值的高效查询。
- 堆：堆天然适合用来实现优先队列。

下面我们将使用堆来进行实现：

```swift
public struct PriorityQueue<T> {
  fileprivate var heap: Heap<T>

  public init(sort: (T, T) -> Bool) {
    heap = Heap(sort: sort)
  }

  public var isEmpty: Bool {
    return heap.isEmpty
  }

  public var count: Int {
    return heap.count
  }

  public func peek() -> T? {
    return heap.peek()
  }

  public mutating func enqueue(element: T) {
    heap.insert(element)
  }

  public mutating func dequeue() -> T? {
    return heap.remove()
  }

  public mutating func changePriority(index i: Int, value: T) {
    return heap.replace(index: i, value: value)
  }
}
```

