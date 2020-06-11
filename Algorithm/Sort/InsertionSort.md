# 插入排序

### 性能分析

插入排序的最好时间复杂度为 O(n)；最坏时间复杂度为 O(n^2)；平均时间复杂度为 O(n^2)。

### 适用场景

- 在数据规模较小（<1000）的情况下，插排效率很高
- 如果数据集中大部分元素是有序的

### 特点

- 实现简单
- 稳定
- 空间复杂度为 O(1)

### 排序过程

插入排序算法有点类似于打扑克牌时，从牌桌上逐一拿起扑克牌然后在手上进行排序的过程：依次从原数组中取出元素，插入到另一个数组中，并使这个数组保持有序，直到原数组中的所有元素都被取出。 这也就是被成为插入排序的原因。

实际上，并不需要创建一个单独的数组来进行排序。我们只需要将原数组划分成两个部分：已排序和未排序。然后从未排序部分取出数据放入到已排序部分：

1. 从第一个元素开始，该元素可以认为已经被排序；
2. 取出下一个元素，在已经排序的元素序列中从后向前扫描；
3. 如果该元素（已排序）大于新元素，将该元素移到下一位置；
4. 重复步骤3，直到找到已排序的元素小于或者等于新元素的位置；
5. 将新元素插入到该位置后；
6. 重复步骤2~5。

```swift
func insertionSort(_ array: [Int]) -> [Int] {
    guard array.count > 0 else { return array }
    
    var newArray = array
    for i in 1..<newArray.count {
        
        var preIndex = i - 1
        let current = newArray[i]
        
        while preIndex >= 0 &&  current < newArray[preIndex] {
            newArray[preIndex + 1] = newArray[preIndex]
            preIndex -= 1
        }
        
        newArray[preIndex + 1] = current
    }
    return newArray
}
```


在上面的代码中，出于跟 Swift 的 `sort()` 方法统一，我们将原来的数组拷贝了一份，并在新的数组上完成排序操作。

代码中有两个循环

- 外层循环依次从**未排序分区**取出元素
- 内层循环将取出的元素从后向前依次跟**已排序分区**的元素进行比较并将较大的元素向后移动

### 泛化

```swift
func insertionSort<T>(_ array: [T], _ isOrderBefore: (T, T) -> Bool) -> [T] {
    guard array.count > 0 else { return array }
    
    var newArray = array
    for i in 1..<newArray.count {
        
        var preIndex = i - 1
        let current = newArray[i]
        
        while preIndex >= 0 &&  isOrderBefore(current, newArray[preIndex]) {
            newArray[preIndex + 1] = newArray[preIndex]
            preIndex -= 1
        }
        
        newArray[preIndex + 1] = current
    }
    return newArray
}
```

参考链接：

- [维基百科：插入排序](https://zh.wikipedia.org/wiki/%E6%8F%92%E5%85%A5%E6%8E%92%E5%BA%8F)
- [Wikipedia: Insertion sort](https://en.wikipedia.org/wiki/Insertion_sort)