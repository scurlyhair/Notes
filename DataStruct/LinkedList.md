# 链表

链表（Linked list）也是一种线性表，与数组不同的是，数组会申请一段连续的内存空间来存放内容，链表的储存地址是分散的，在每一个节点里储存下一个节点的指针(Pointer)：

```
+--------+    +--------+    +--------+    +--------+
|        |    |        |    |        |    |        |
| node 0 |--->| node 1 |--->| node 2 |--->| node 3 |
|        |    |        |    |        |    |        |
+--------+    +--------+    +--------+    +--------+
```

还有一种链表双向链表，在其节点中同时储存了前一个节点和后一个节点的指针：

```
+--------+    +--------+    +--------+    +--------+
|        |--->|        |--->|        |--->|        |
| node 0 |    | node 1 |    | node 2 |    | node 3 |
|        |<---|        |<---|        |<---|        |
+--------+    +--------+    +--------+    +--------+
```

为了标识链表的头部，一般会储存头部节点的指针。当然，有时候还需要储存尾部指针：

```
         +--------+    +--------+    +--------+    +--------+
head --->|        |--->|        |--->|        |--->|        |---> nil
         | node 0 |    | node 1 |    | node 2 |    | node 3 |
 nil <---|        |<---|        |<---|        |<---|        |<--- tail
         +--------+    +--------+    +--------+    +--------+
```

获取链表中的某个节点需要从`head`/`tail`开始，沿着 `next`/`previous` 指针进行查找。其时间复杂度是 O(n) 。但是当我们找到一个元素后，对其进行的 `insert`/`delete` 方法会非常快，因为这仅仅是一些指针的修改。它不必像数组那样对一大块内存空间来回拷贝。

根据链表的特性，尽量选择在头部或者尾部进行插入操作，将操作的时间复杂度降低到 O(1)。

链表的一个典型应用就是用来实现队列。由链表实现的队列进行出队操作时，仅仅是将 `head` 指针指向链表的第二个节点，而不必像数组一样对将所有元素进行移动。

### 实现链表

定义一个节点：

```swift
public class LinkedListNode<T> {
  var value: T
  var next: LinkedListNode?
  weak var previous: LinkedListNode?

  public init(value: T) {
    self.value = value
  }
}
```
可以看看到，节点中储存了`next` 和 `previous` 两个指针，所以这是双向链表的节点。如果仔细看的话你会发现，我们使用了 `weak` 关键字来修饰 `previous` 指针，从而打破两个节点的循环引用。

接下来是链表的实现：

```swift
public class LinkedList<T> {
  public typealias Node = LinkedListNode<T>

  private var head: Node?

  public var isEmpty: Bool {
    return head == nil
  }

  public var first: Node? {
    return head
  }
}
```
这里我们使用 `typealias` 给 `LinkedListNode<T>` 定义了一个别名 `Node`，来简洁地描述一个节点。

在链表中保存了一个 `head` 指针，指向链表的头部。如果 `head` 指针是 `nil`，那么这就是一个空的链表。`first` 属性返回链表的头部元素。

> 当然，我们也可以再保存一个 `tail` 来描述链表的尾部信息，合理设计这些数据结构可以让一些操作变得更加便捷和高效。

下面我们为其添加一个 `last` 属性：

```swift
public var last: Node? {
    guard var node = head else {
      return nil
    }
  
    while let next = node.next {
      node = next
    }
    return node
  }
```

可以看到，如果我们保存了一个 `tail` 的引用，那么 `last` 属性只需要直接返回 `tail` 就可以了。但在这里我们需要遍历整个链表，当链表很长的时候，开销会很大。

接下来我们为链表创建一个添加元素的方法：

```swift
public func append(value: T) {
    let newNode = Node(value: value)
    if let lastNode = last {
      newNode.previous = lastNode
      lastNode.next = newNode
    } else {
      head = newNode
    }
  }
```

这里要注意 `next` 和 `previous` 指针的赋值。

在向其中添加元素的时候：

```swift
list.append("Hello")
list.isEmpty         // false
list.first!.value    // "Hello"
list.last!.value     // "Hello"

         +---------+
head --->|         |---> nil
         | "Hello" |
 nil <---|         |
         +---------+

list.append("World")
list.first!.value    // "Hello"
list.last!.value     // "World"

         +---------+    +---------+
head --->|         |--->|         |---> nil
         | "Hello" |    | "World" |
 nil <---|         |<---|         |
         +---------+    +---------+

```

然后为其添加一个 `count` 属性，来描述链表中的元素数量。

```swift
public var count: Int {
    guard var node = head else {
      return 0
    }
  
    var count = 1
    while let next = node.next {
      node = next
      count += 1
    }
    return count
}
```
这种方法获取元素个数的时间复杂度是 O(n)。当然我们也可以维护一个简单的 `count: Int` 属性，在插入和删除操作的时候，对其进行更新。这样可以将时间复杂度降低到 O(1)。

有时候我们需要根据索引，获取指定位置的节点：

```
public func node(atIndex index: Int) -> Node {
    if index == 0 {
      return head!
    } else {
      var node = head!.next
      for _ in 1..<index {
        node = node?.next
        if node == nil { //(*1)
          break
        }
      }
      return node!
    }
}
```

注意：发生越界时，将会发生 crash。

得益于 Swift 的 `subscript` 机制，可以实现一个类似数组的下标操作：

```swift
public subscript(index: Int) -> T {
    let node = node(atIndex: index)
    return node.value
}
```
现在，我们可以通过下标来获取链表中的指定元素：

```swift
list[0]   // "Hello"
list[1]   // "World"
list[2]   // crash!
```

向指定位置插入元素的方法：

```swift
public func insert(_ node: Node, atIndex index: Int) {
   let newNode = node
   if index == 0 {
     newNode.next = head                      
     head?.previous = newNode
     head = newNode
   } else {
     let prev = self.node(atIndex: index-1)
     let next = prev.next

     newNode.previous = prev
     newNode.next = prev.next
     prev.next = newNode
     next?.previous = newNode
   }
}
```

添加移除方法：

```
// 移除所有节点
public func removeAll() {
    head = nil
}
// 移除指定节点
public func remove(node: Node) -> T {
    let prev = node.previous
    let next = node.next

    if let prev = prev {
      prev.next = next
    } else {
      head = next
    }
    next?.previous = prev

    node.previous = nil
    node.next = nil
    return node.value
}
```

### 扩展

打印链表：

```swift
extension LinkedList: CustomStringConvertible {
  public var description: String {
    var s = "["
    var node = head
    while node != nil {
      s += "\(node!.value)"
      node = node!.next
      if node != nil { s += ", " }
    }
    return s + "]"
  }
}

// 将会打印： [Hello, Swift, World]
```

链表翻转：

```swift
public func reverse() {
    var node = head
    tail = node // If you had a tail pointer
    while let currentNode = node {
      node = currentNode.next
      swap(&currentNode.next, &currentNode.previous)
      head = currentNode
    }
}
```

map 方法：

```swift
public func map<U>(transform: T -> U) -> LinkedList<U> {
    let result = LinkedList<U>()
    var node = head
    while node != nil {
      result.append(transform(node!.value))
      node = node!.next
    }
    return result
}
```

filter 方法：

```swift
public func filter(predicate: T -> Bool) -> LinkedList<T> {
    let result = LinkedList<T>()
    var node = head
    while node != nil {
      if predicate(node!.value) {
        result.append(node!.value)
      }
      node = node!.next
    }
    return result
}
```

参考链接：

- [https://github.com/raywenderlich/swift-algorithm-club/tree/master/Linked%20List](https://github.com/raywenderlich/swift-algorithm-club/tree/master/Linked%20List)
