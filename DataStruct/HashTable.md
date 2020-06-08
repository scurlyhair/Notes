# 散列表

散列表也称为哈希表（Hash Table）提供了通过 key 来存取数据的方法。

散列表实际上就是一个数组，只不过元素的位置是通过将 key 进行哈希运算得到的：

```swift
hashTable["firstName"] = "Steve"

	The hashTable array:
	+--------------+
	| 0:           |
	+--------------+
	| 1:           |
	+--------------+
	| 2:           |
	+--------------+
	| 3: firstName |---> Steve
	+--------------+
	| 4:           |
	+--------------+
```
散列表的核心就是哈希算法。

比如下面这行语句：

```swift
hashTable["firstName"] = "Steve"
```
哈希表拿到 key `"firstName"`，然后向它索要其 `hashValue`。因此，所有的 key 都应该遵循 `Hashable`。

```swift
"firstName".hashValue
```
会返回一个很大的整数： -4799450059917011053。

这些数字对于描述哈希表中的数组来说太大了。一种常见的做法是先求得绝对值，然后使用数组的长度对该绝对值进行模运算。

例如数组长度是 5，那么 "firstName" 的索引就是 `abs(-4799450059917011053) %5 = 3`。

使用这种方式存取值的是非常高效的，先计算 key 的哈希值，然后算出对应的 index，然后从数组中取出元素。所以其时间复杂度都是 O(1)。

> 由于经过哈希运算之后得到的 index 具有不确定性，因此哈希表中的元素是无序的。

### 哈希碰撞

我们需要注意到一个问题，在对 key 的哈希值取模的时候，不一样的 key 可能会产生同一个 index，这种情况被称作**哈希碰撞**。

降低哈希碰撞出现的方法之一是使用一个大的数组，来减少出现相同 index 的可能性。

另一种方法就是采用素数（质数）的数组长度。

但是上面两种方法只能减少碰撞，当碰撞发生时，我们还需要一定的方法去处理它。比如下面的**拉链法**：

```swift
buckets:
	+-----+
	|  0  |
	+-----+     +----------------------------+
	|  1  |---> | hobbies: Programming Swift |
	+-----+     +----------------------------+
	|  2  |
	+-----+     +------------------+     +----------------+
	|  3  |---> | firstName: Steve |---> | lastName: Jobs |
	+-----+     +------------------+     +----------------+
	|  4  |
	+-----+
```

可以看到，keys 和 values 并不是直接储存在数组中，实际上每一个数组的元素都是一条拉链，这条拉链上可能会有 0 个 或者多个键值对。数组元素通常被称为 _buckets_ （桶），拉链被叫做 _chains_ （链）。

当我们使用下面的语句取值时：

```swift
let x = hashTable["lastName"]
```

会先对 `lastName` 取哈希，然后取模，得到 3，之后我们会沿着这个位置的链去比对 key，如果找到就将该元素返回。

> 当然还有其他解决冲突的方式，比如开放定址法：从发生冲突的那个单元起，按照一定的次序，从哈希表中找到一个空闲的单元。然后把发生冲突的元素存入到该单元。

### 实现

下面，让我们亲自动手来实现哈希表：

```swift
public struct HashTable<Key: Hashable, Value> {
  private typealias Element = (key: Key, value: Value)
  private typealias Bucket = [Element]
  private var buckets: [Bucket]

  private(set) public var count = 0
  
  public var isEmpty: Bool { return count == 0 }

  public init(capacity: Int) {
    assert(capacity > 0)
    buckets = Array<Bucket>(repeatElement([], count: capacity))
  }
```

我们定义了两个泛型：`Key` （要求 Hashable）和 `Value`，以及两个别名：`Element` 是需要保存在拉链中的键值对， `Bucket` 可以看做是拉链数组，其中保存了 `Element`。

`buckets` 数组用来储存拉链，我们会在哈希表的构造方法中定义数组的容量。

`count` 属性用来描述哈希表中储存的元素的个数。

可以通过下面的方式创建一个哈希表实例：

```swift
var hashTable = HashTable<String, String>(capacity: 5)
```
接下来，加入一些必要的方法。

首先需要一个辅助函数，传入 Key，计算它的索引：

```swift
private func index(forKey key: Key) -> Int {
    return abs(key.hashValue % buckets.count)
  }
```

一个哈希表需要实现以下四个操作：

- 插入元素
- 查询元素
- 修改元素
- 删除元素

```swift
// lookup
public func value(forKey key: Key) -> Value? {
    let index = self.index(forKey: key)
    for element in buckets[index] {
      if element.key == key {
        return element.value
      }
    }
    return nil  // key not in hash table
  }
  // update
  public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
    let index = self.index(forKey: key)
    
    // Do we already have this key in the bucket?
    for (i, element) in buckets[index].enumerated() {
      if element.key == key {
        let oldValue = element.value
        buckets[index][i].value = value
        return oldValue
      }
    }
    
    // This key isn't in the bucket yet; add it to the chain.
    buckets[index].append((key: key, value: value))
    count += 1
    return nil
  }
  // delete
  public mutating func removeValue(forKey key: Key) -> Value? {
    let index = self.index(forKey: key)

    // Find the element in the bucket's chain and remove it.
    for (i, element) in buckets[index].enumerated() {
      if element.key == key {
        buckets[index].remove(at: i)
        count -= 1
        return element.value
      }
    }
    return nil  // key not in hash table
  }
```

我们可以定义一个下标函数来合并这些操作：

```swift
public subscript(key: Key) -> Value? {
    get {
      return value(forKey: key)
    }
    set {
      if let value = newValue {
        updateValue(value, forKey: key)
      } else {
        removeValue(forKey: key)
      }
    }
  }
```

然后实现很简单地调用：

```swift
hashTable["firstName"] = "Steve"   // insert
let x = hashTable["firstName"]     // lookup
hashTable["firstName"] = "Tim"     // update
hashTable["firstName"] = nil       // delete
```

### 扩容

我们编写的这个哈希表使用数组来实现的，在实例化的时候一般会定义一个比需要储存元素数量更大的容量。

或者我们监测元素的数量，当其占用率（已有元素/容量）大于 75% 时对其进行扩容操作。



参考链接：

- [https://github.com/raywenderlich/swift-algorithm-club/tree/master/Hash%20Table](https://github.com/raywenderlich/swift-algorithm-club/tree/master/Hash%20Table)
- [解决哈希冲突的常用方法分析](https://www.jianshu.com/p/4d3cb99d7580)