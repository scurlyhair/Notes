# 线性查找

线性查找（Linear search）又称顺序查找。指按一定的顺序检查数组中每一个元素，直到找到所要寻找的特定值为止。是最简单的一种搜索算法。

线性搜索的时间复杂度是 O(n)。

### 实现代码

实现了 Equatable 协议的元素：

```swift
func linearSearch<T: Equatable>(_ array: [T], _ object: T) -> Int {
  for (index, obj) in array.enumerated() where obj == object {
    return index
  }
  return -1
}
```

根据条件，进行比较：

```swift
func linearSearch<T>(_ array: [T], _ condition: (T)-> Bool) -> Int {
    for (index, obj) in array.enumerated() where condition(obj) {
        return index
    }
    return -1
}
```
