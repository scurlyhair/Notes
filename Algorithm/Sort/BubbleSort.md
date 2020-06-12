# 冒泡排序

### 性能分析

冒泡排序的最好时间复杂度为 O(n)、最坏、平均时间复杂度都是 O(n^2)。

### 适用场景

由于它的简单，被用来向程序设计入门的学生介绍算法的概念。

### 特点

- 实现简单
- 稳定
- 空间复杂度为 O(1)

### 排序过程

![BubbleSort_01](BubbleSort_01.gif)

它重复地走访过要排序的数列，一次比较两个元素，如果他们的顺序错误就把他们交换过来。走访数列的工作是重复地进行直到没有再需要交换，也就是说该数列已经排序完成。这

冒泡排序就是因为越小的元素会经由交换慢慢“浮”到数列的顶端而得名。有时候也被成为鸡尾酒排序，因为它重复地在数列的一端到另一端穿梭。

1. 从第一个开始，依次比较相邻的元素。如果前一个比后一个大，就交换他们两个。当所有元素都被比较过之后，最大的一个元素就被调整到了数组末尾。
2. 再从第一个开始，重复步骤 1，直到前 n - 1 个元素都完成比较之后，最后面 2 个元素就是有序的。
3. ......
4. 持续每次对越来越少的元素重复上面的步骤，直到没有任何一对数字需要比较。

```swift
func bubbleSort(_ array: [Int]) -> [Int] {
    guard array.count > 1 else { return array }
    
    var newArray = array
    
    for i in 0..<newArray.count {
      for j in 1..<newArray.count - i {
        if newArray[j] < newArray[j-1] {
          let tmp = newArray[j-1]
          newArray[j-1] = newArray[j]
          newArray[j] = tmp
        }
      }
    }
    return newArray
}
```

### 泛化

```swift
func bubbleSort<T>(_ array: [T], _ orderCriteria: (T, T) -> Bool) -> [T] {
    guard array.count > 1 else { return array }
    
    var newArray = array
    
    for i in 0..<newArray.count {
      for j in 1..<newArray.count - i {
        if orderCriteria(newArray[j], newArray[j-1]) {
          let tmp = newArray[j-1]
          newArray[j-1] = newArray[j]
          newArray[j] = tmp
        }
      }
    }
    return newArray
}
```


参考链接：

- [Wikipedia: BubbleSort](https://en.wikipedia.org/wiki/Bubble_sort)
- [维基百科：冒泡排序](https://zh.wikipedia.org/wiki/%E5%86%92%E6%B3%A1%E6%8E%92%E5%BA%8F)
- [十大经典排序算法（动图演示）](https://www.cnblogs.com/onepixel/p/7674659.html)