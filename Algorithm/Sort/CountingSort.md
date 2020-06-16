# 计数排序

计数排序（Counting sort）不是基于比较的稳定的线性时间排序算法。

计数排序要求输入的数据必须是有确定范围的整数。

### 性能分析

计数排序的最优时间复杂度、最坏时间复杂度、平均时间复杂度都是 O(n + k)。

### 适用场景

由于用来计数的数组 C 的长度取决于待排序数组中数据的范围（等于待排序数组的最大值与最小值的差加上1），这使得计数排序对于数据范围很大的数组，需要大量时间和内存。例如：计数排序是用来排序0到100之间的数字的最好的算法。

### 特点

- 稳定
- 最佳的快排变化版本空间复杂度为 O(n + k)

### 排序过程

设数组 C 为计数数组。

1. 找出待排序的数组中最大和最小的元素
2. 统计数组中每个值为 i 的元素出现的次数，存入数组 C 的第 i 项
3. 对所有的计数累加（从 C 中的第一个元素开始，每一项和前一项相加）
4. 反向填充目标数组：将每个元素 i 放在新数组的第 C[i] 项，每放一个元素就将 C[i] 减去 1

我们可以通过一个例子来理解：

```
[ 10, 9, 8, 7, 1, 2, 7, 3 ]
```

统计每个元素出现的次数：

```swift
let maxElement = array.max() ?? 0

  var countArray = [Int](repeating: 0, count: Int(maxElement + 1))
  for element in array {
    countArray[element] += 1
  }
```

结果：

```
Index 0 1 2 3 4 5 6 7 8 9 10
Count 0 1 1 1 0 0 0 2 1 1 1
```

 对所有的计数累加（从 C 中的第一个元素开始，每一项和前一项相加）
 
```swift
  for index in 1 ..< countArray.count {
    let sum = countArray[index] + countArray[index - 1]
    countArray[index] = sum
  }
```

结果：
 
 ```
 Index 0 1 2 3 4 5 6 7 8 9 10
Count 0 1 2 3 3 3 3 5 6 7 8
 ```

反向填充目标数组：将每个元素 i 放在新数组的第 C[i] 项，每放一个元素就将 C[i] 减去 1

```swift
  var sortedArray = [Int](repeating: 0, count: array.count)
  for element in array {
    countArray[element] -= 1
    sortedArray[countArray[element]] = element
  }
  return sortedArray
```

结果：
```
Index  0 1 2 3 4 5 6 7
Output 1 2 3 7 7 8 9 10
```





参考链接：

- [维基百科：计数排序](https://zh.wikipedia.org/wiki/%E8%AE%A1%E6%95%B0%E6%8E%92%E5%BA%8F)
- [https://github.com/raywenderlich/swift-algorithm-club/tree/master/Counting%20Sort](https://github.com/raywenderlich/swift-algorithm-club/tree/master/Counting%20Sort)