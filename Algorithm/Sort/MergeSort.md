# 归并排序

归并排序（Merge sort）是采用分治法（Divide and Conquer）的一个非常典型的应用，且各层分治递归可以同时进行。

> 分治法的核心思想就是将大问题切割成小问题来解决。

### 性能分析

归并排序的最优时间复杂度、最坏时间复杂度和平均时间复杂度都是 O(n log n)。

### 适用场景

归并排序的效率很高的排序方法，是一种稳定排序，但需要额外 n 的空间来完成。

另外，元素是否有序并不会对其排序时间造成影响。

### 特点

- 稳定
- 空间复杂度为 O(n)

### 排序过程

![MergeSort_01](MergeSort_01.gif)

归并排序的排序过程可以简单描述为先分开，再合并。

归并排序的有两种实现方式：自顶向下进行递归、自底到上进行迭代。

**自顶向下**

- 找到数组的中间索引，将其分成两份
- 对每个子数组继续切割，直到整个数组最终被分割成 n 个只包含 1 个元素的子数组。
- 将被切割的子数进行合并，每次都保证其中的元素有序

```swift
func mergeSort(_ array: [Int]) -> [Int] {
  guard array.count > 1 else { return array }    // 1

  let middleIndex = array.count / 2              // 2

  let leftArray = mergeSort(Array(array[0..<middleIndex]))             // 3

  let rightArray = mergeSort(Array(array[middleIndex..<array.count]))  // 4

  return merge(leftPile: leftArray, rightPile: rightArray)             // 5
}

func merge(leftPile: [Int], rightPile: [Int]) -> [Int] {
  // 1
  var leftIndex = 0
  var rightIndex = 0

  // 2
  var orderedPile = [Int]()
  orderedPile.reserveCapacity(leftPile.count + rightPile.count)

  // 3
  while leftIndex < leftPile.count && rightIndex < rightPile.count {
    if leftPile[leftIndex] < rightPile[rightIndex] {
      orderedPile.append(leftPile[leftIndex])
      leftIndex += 1
    } else if leftPile[leftIndex] > rightPile[rightIndex] {
      orderedPile.append(rightPile[rightIndex])
      rightIndex += 1
    } else {
      orderedPile.append(leftPile[leftIndex])
      leftIndex += 1
      orderedPile.append(rightPile[rightIndex])
      rightIndex += 1
    }
  }

  // 4
  while leftIndex < leftPile.count {
    orderedPile.append(leftPile[leftIndex])
    leftIndex += 1
  }

  while rightIndex < rightPile.count {
    orderedPile.append(rightPile[rightIndex])
    rightIndex += 1
  }

  return orderedPile
}
```
**由底向上**

```swift
func mergeSortBottomUp<T>(_ a: [T], _ isOrderedBefore: (T, T) -> Bool) -> [T] {
  let n = a.count

  var z = [a, a]      // 1
  var d = 0

  var width = 1
  while width < n {   // 2

    var i = 0
    while i < n {     // 3

      var j = i
      var l = i
      var r = i + width

      let lmax = min(l + width, n)
      let rmax = min(r + width, n)

      while l < lmax && r < rmax {                // 4
        if isOrderedBefore(z[d][l], z[d][r]) {
          z[1 - d][j] = z[d][l]
          l += 1
        } else {
          z[1 - d][j] = z[d][r]
          r += 1
        }
        j += 1
      }
      while l < lmax {
        z[1 - d][j] = z[d][l]
        j += 1
        l += 1
      }
      while r < rmax {
        z[1 - d][j] = z[d][r]
        j += 1
        r += 1
      }

      i += width*2
    }

    width *= 2
    d = 1 - d      // 5
  }
  return z[d]
}
```



参考链接：

- [维基百科：归并排序](https://zh.wikipedia.org/wiki/%E5%BD%92%E5%B9%B6%E6%8E%92%E5%BA%8F)
- [https://github.com/raywenderlich/swift-algorithm-club/tree/master/Merge%20Sort](https://github.com/raywenderlich/swift-algorithm-club/tree/master/Merge%20Sort)