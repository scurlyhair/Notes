# 二叉查找树

二叉查找树（BST）是一种特殊的二叉树，对于其中任意一个节点，其左孩子小于当前节点，右孩子大于当前节点，在插入或者删除之后依然保持有序。

下图就是一个典型的 BST：

![BinarySearchTree_01](BinarySearchTree_01.png)

### 插入新节点

在插入一个新节点的时候，会跟 root 节点进行比较，如果比 root 小就跟 root 的左孩子比较，反之，跟 root 的右孩子比较。就这样一直递归向下查找，直到找到合适的空位插入。

例如我们要在上图中插入一个新的节点 9，会先跟 7 进行比较，然后 10，因为它比 10 小，且 10 左孩子为空， 所以将 9 放在 10 的左孩子位置。

![BinarySearchTree_02](BinarySearchTree_02.png)

这个查找的时间复杂度是 O(h)，h 是树的高度。

### 查找

查找节点跟插入节点类似，：

- 如果比该节点小就去其左孩子查找
- 如果比该节点大就去其右孩子查找
- 如果跟该节点的值相等就返回此节点

比如查找 5：

![BinarySearchTree_03](BinarySearchTree_03.png)

查找节点的时间复杂度是 O(h)，假设一棵有上百万个节点的树，如果这棵树平衡度很高，那么最多需要 20 多步就能找到任意一个元素。（类似有序数组中的二分查找）

### 遍历

有三种方法来对 BST 进行遍历：

- 中序遍历（In-order）：先左孩子，然后当前节点，最后右孩子。
- 前序遍历（Pre-order）：先当前节点，然后左孩子，最后右孩子。
- 后序遍历（Post-order）：先左孩子，然后右孩子，最后当前节点。

遍历也是以递归的方式进行。

中序遍历的结果中元素是从小到大排列的。比如中序遍历上面的树，会打印：`1, 2, 5, 7, 9, 10`：

![BinarySearchTree_04](BinarySearchTree_04.png)

### 删除节点

删除节点很简单。在删除一个节点之后我们需要让该节点的左侧子节点中最大的节点，或者右侧子节点中最小的节点放到被删除的节点。

![BinarySearchTree_05](BinarySearchTree_05.png)

如果被删除的节点没有孩子，那么直接将该节点置空。

### 实现

说了这么多 BST 的理论知识，下面我们将使用 Swift 来实现它。

首先我们将使用**类**构建一个 BST，随后再尝试使用**枚举**来实现。

```swift
public class BinarySearchTree<T: Comparable> {
  private(set) public var value: T
  private(set) public var parent: BinarySearchTree?
  private(set) public var left: BinarySearchTree?
  private(set) public var right: BinarySearchTree?

  public init(value: T) {
    self.value = value
  }

  public var isRoot: Bool {
    return parent == nil
  }

  public var isLeaf: Bool {
    return left == nil && right == nil
  }

  public var isLeftChild: Bool {
    return parent?.left === self
  }

  public var isRightChild: Bool {
    return parent?.right === self
  }

  public var hasLeftChild: Bool {
    return left != nil
  }

  public var hasRightChild: Bool {
    return right != nil
  }

  public var hasAnyChild: Bool {
    return hasLeftChild || hasRightChild
  }

  public var hasBothChildren: Bool {
    return hasLeftChild && hasRightChild
  }

  public var count: Int {
    return (left?.count ?? 0) + 1 + (right?.count ?? 0)
  }
}
```

上面的代码定义了一个 `BinarySearchTree` 类型，可以使用下面的的语句来实例化：

```swift
let tree = BinarySearchTree<Int>(value: 7)
```

**插入**

```swift
public func insert(value: T) {
    if value < self.value {
      if let left = left {
        left.insert(value: value)
      } else {
        left = BinarySearchTree(value: value)
        left?.parent = self
      }
    } else {
      if let right = right {
        right.insert(value: value)
      } else {
        right = BinarySearchTree(value: value)
        right?.parent = self
      }
    }
  }
```

> 需要注意的是，为了保证 BST 的有序性，每次的插入操作都要从 root 节点开始。
> 
> 在上面的实现中，一个相同大小的元素将会被插入到右孩子节点。

为了快速地从数组创建一个 BST，我们可以为它编写一个遍历构造器：

```swift
public convenience init(array: [T]) {
    precondition(array.count > 0)
    self.init(value: array.first!)
    for v in array.dropFirst() {
      insert(value: v)
    }
  }
```

从数组创建二叉查找树：

```swift
let tree = BinarySearchTree<Int>(array: [7, 2, 5, 10, 9, 1])
```

**debug 输出**

在跟复杂的数据结构打交道时，最好是可以将其内容以便于阅读的方式打印出来。

```swift
extension BinarySearchTree: CustomStringConvertible {
  public var description: String {
    var s = ""
    if let left = left {
      s += "(\(left.description)) <- "
    }
    s += "\(value)"
    if let right = right {
      s += " -> (\(right.description))"
    }
    return s
  }
}
```
当调用 `print(tree)` 的时候，会进行如下输出：

```
((1) <- 2 -> (5)) <- 7 -> ((9) <- 10)
```

**查询**

```swift
public func search(value: T) -> BinarySearchTree? {
    if value < self.value {
      return left?.search(value)
    } else if value > self.value {
      return right?.search(value)
    } else {
      return self  // found it!
    }
  }
```
> 得益于 Swift 的可选链机制，当我们写下诸如 `left?.search(value)` 的代码时，如果 `left` 节点是空那么该语句就是 `nil`。所以我们没必要使用 `if` 进行 `nil` 的条件判断。

虽然查找是一个递归函数，但我们也可以使用迭代来实现：

```swift
public func search(_ value: T) -> BinarySearchTree? {
    var node: BinarySearchTree? = self
    while let n = node {
      if value < n.value {
        node = n.left
      } else if value > n.value {
        node = n.right
      } else {
        return node
      }
    }
    return nil
  }
```

另外需要注意的是，如果 BST 中有多个相等的元素，`search` 返回的是层数最高的那个，因为搜索是从 root 节点向下进行的。

**遍历**

回忆一下遍历的三种方式：中序（In-order）、前序（Pre-order）、后序（Post-order）。

```swift
public func traverseInOrder(process: (T) -> Void) {
    left?.traverseInOrder(process: process)
    process(value)
    right?.traverseInOrder(process: process)
}

public func traversePreOrder(process: (T) -> Void) {
    process(value)
    left?.traversePreOrder(process: process)
    right?.traversePreOrder(process: process)
}

public func traversePostOrder(process: (T) -> Void) {
    left?.traversePostOrder(process: process)
    right?.traversePostOrder(process: process)
    process(value)
}
```

除了顺序不同，其他都是相同的。所有的工作都是递归实现的。

比如我们中序遍历并打印一个 BST 实例：

```swift
tree.traverseInOrder { value in print(value) }
```

将会打印：

```
1
2
5
7
9
10
```

遍历函数通过传递一个闭包来提供对这些元素的操作。类似的，我们也可以实现 `map` 或是 `filter` 等函数。

例如实现 map 函数：

```swift
public func map(formula: (T) -> T) -> [T] {
    var a = [T]()
    if let left = left { a += left.map(formula: formula) }
    a.append(formula(value))
    if let right = right { a += right.map(formula: formula) }
    return a
  }
```

它会让每一个节点都调用 `formular` 闭包，然后将结果添加到结果数组中。

**删除**

我们可以利用一些辅助函数让代码的可读性更好：

```swift
 private func reconnectParentTo(node: BinarySearchTree?) {
    if let parent = parent {
      if isLeftChild {
        parent.left = node
      } else {
        parent.right = node
      }
    }
    node?.parent = parent
  }
```
改变一棵树的结构实际上是修改其中节点的 `parent`、`left` 和 `right` 三个指针。上面的辅助函数所做的就是：拿到当前节点（`self`）的父节点，然后将当前节点替换成作为参数传入的节点。

我们还需要一个函数，（递归地）获取一个节点的最小（或最大）子节点。

```swift
public func minimum() -> BinarySearchTree {
    var node = self
    while let next = node.left {
      node = next
    }
    return node
  }

  public func maximum() -> BinarySearchTree {
    var node = self
    while let next = node.right {
      node = next
    }
    return node
  }
```
然后我们可以完成删除函数了：

```swift
@discardableResult public func remove() -> BinarySearchTree? {
    let replacement: BinarySearchTree?

    // Replacement for current node can be either biggest one on the left or
    // smallest one on the right, whichever is not nil
    if let right = right {
      replacement = right.minimum()
    } else if let left = left {
      replacement = left.maximum()
    } else {
      replacement = nil
    }

    replacement?.remove()

    // Place the replacement on current node's position
    replacement?.right = right
    replacement?.left = left
    right?.parent = replacement
    left?.parent = replacement
    reconnectParentTo(node:replacement)

    // The current node is no longer part of the tree, so clean it up.
    parent = nil
    left = nil
    right = nil

    return replacement
  }
```

**高度**

获取 BST 的最大高度：

```swift
public func height() -> Int {
    if isLeaf {
      return 0
    } else {
      return 1 + max(left?.height() ?? 0, right?.height() ?? 0)
    }
  }
```

由于查找高度会遍历树中的所有节点，所以其时间复杂度是 O(n)。

**深度**

当然你也可以计算一个节点到根节点的深度：

```swift
public func depth() -> Int {
    var node = self
    var edges = 0
    while let parent = node.parent {
      node = parent
      edges += 1
    }
    return edges
  }
```
由于是从该节点向上沿着父节点进行查找直到 root 节点，因此时间复杂度是 O(h)。

**前驱和后继**

BST 是有序的，但并不意味着两个连续的值彼此连接。

![BinarySearchTree_02](BinarySearchTree_02.png)

你可以看到，如果按照顺序排列 5 和 7 是相邻的两个数字，但他们并不在一起。

前驱函数 `predecessor()` 返回当前节点的前一个元素（将树中所有元素从小到大有序排列），而后继函数 `successor()` 则返回当前节点后面的一个元素。

```swift
 public func predecessor() -> BinarySearchTree<T>? {
    if let left = left {
      return left.maximum()
    } else {
      var node = self
      while let parent = node.parent {
        if parent.value < value { return parent }
        node = parent
      }
      return nil
    }
  }
  
 public func successor() -> BinarySearchTree<T>? {
    if let right = right {
      return right.minimum()
    } else {
      var node = self
      while let parent = node.parent {
        if parent.value > value { return parent }
        node = parent
      }
      return nil
    }
}
```

这两个函数的时间复杂度都是 O(h)。

### 使用枚举实现

在前面我们已经使用类实现了 BST，现在我们尝试使用枚举来实现。

与 class  实现不一样的是，enum 是值类型的，如果 BST 中的任何一个节点发生改变，都会将整棵树拷贝一遍。至于那种实现比较好，还需要根据实际需求来取舍。

```swift
public enum BinarySearchTree<T: Comparable> {
  case Empty
  case Leaf(T)
  indirect case Node(BinarySearchTree, T, BinarySearchTree)
  
  public var count: Int {
    switch self {
    case .Empty: return 0
    case .Leaf: return 1
    case let .Node(left, _, right): return left.count + 1 + right.count
    }
  }

  public var height: Int {
    switch self {
    case .Empty: return -1
    case .Leaf: return 0
    case let .Node(left, _, right): return 1 + max(left.height, right.height)
    }
  }
  
  public func insert(newValue: T) -> BinarySearchTree {
    switch self {
    case .Empty:
      return .Leaf(newValue)

    case .Leaf(let value):
      if newValue < value {
        return .Node(.Leaf(newValue), value, .Empty)
      } else {
        return .Node(.Empty, value, .Leaf(newValue))
      }

    case .Node(let left, let value, let right):
      if newValue < value {
        return .Node(left.insert(newValue), value, right)
      } else {
        return .Node(left, value, right.insert(newValue))
      }
    }
  }
  
  public func search(x: T) -> BinarySearchTree? {
    switch self {
    case .Empty:
      return nil
    case .Leaf(let y):
      return (x == y) ? self : nil
    case let .Node(left, y, right):
      if x < y {
        return left.search(x)
      } else if y < x {
        return right.search(x)
      } else {
        return self
      }
    }
  }
}
```

实现打印：

```swift
extension BinarySearchTree: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case .Empty: return "."
    case .Leaf(let value): return "\(value)"
    case .Node(let left, let value, let right):
      return "(\(left.debugDescription) <- \(value) -> \(right.debugDescription))"
    }
  }
}
```

### 平衡

当 BST 的左子树和右子树拥有相同数量的节点时，这棵树就是平衡的，在这种情况下树的高度是 _log(n)_ ，即搜索的时间复杂度是 **O(log n)** ，这是一种理想情况。

如果两边的高度差异非常大的话搜索就会变得很慢，在最糟糕的情况下，整棵树变成链表，搜索的时间复杂度会退化到 **O(n)**。

一种保持平衡的方式就是使用完全随机的顺序插入元素，但依然不能保证其平衡性。

另一种方式就是使用自平衡二叉树实现。例如： AVL 树和红黑树。



参考链接：

- [https://github.com/raywenderlich/swift-algorithm-club/tree/master/Binary%20Search%20Tree](https://github.com/raywenderlich/swift-algorithm-club/tree/master/Binary%20Search%20Tree)
