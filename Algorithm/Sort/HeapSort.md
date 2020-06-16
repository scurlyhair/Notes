# 堆排序

堆排序（Heap sort）使用堆来完成排序。

### 性能分析

堆排序的最优时间复杂度、最坏时间复杂度、平均时间复杂度都是 O(n log n)。

### 适用场景

堆排序是一种速度较快的原地排序（in-place）方法，但不是稳定排序。

### 特点

- 不稳定
- 最佳的快排变化版本空间复杂度为 O(1)

### 排序过程

![HeapSort_01](HeapSort_01.gif)

- 使用原始数组初始化一个堆
- 将堆顶元素跟第 n 个元素交换位置
- 使用 `shiftDown` 函数修正前 n - 1 个元素，使他们调整到符合堆的性质。
- 此时，堆中的序列分为两部分：前 n - 1 个元素是无序区，后 1 个元素是有序区。
- 不断将堆顶元素与无序区的最后一个元素交换位置并修正堆，直到无序区只剩下一个元素。

```swift
extension Heap {
  public mutating func sort() -> [T] {
    for i in stride(from: (elements.count - 1), through: 1, by: -1) {
      swap(&elements[0], &elements[i])
      shiftDown(0, heapSize: i)
    }
    return elements
  }
}
```

例如下面的数组：

```
[ 5, 13, 2, 25, 7, 17, 20, 8, 4 ]
```

会初始化成这样的堆：

![HeapSort_02](HeapSort_02.png)

堆内数组：

```
[ 25, 13, 20, 8, 7, 17, 2, 5, 4 ]
```

将堆顶元素跟最后一个元素交换：

```
[ 4, 13, 20, 8, 7, 17, 2, 5, 25 ]
  *                          *
```

实际上会把数组分成两个区：无序区和有序区。

```
[20, 13, 17, 8, 7, 4, 2, 5 | 25]
```

将堆顶元素跟无序区最后一个元素交换：

```
[5, 13, 17, 8, 7, 4, 2, 20 | 25]
 *                      *
```

得到：

```
[17, 13, 5, 8, 7, 4, 2 | 20, 25]
```

重复上面步骤直到无序区（堆区）只剩下一个元素，此时排序完成。

参考链接：

- [https://github.com/raywenderlich/swift-algorithm-club/tree/master/Heap%20Sort](https://github.com/raywenderlich/swift-algorithm-club/tree/master/Heap%20Sort)