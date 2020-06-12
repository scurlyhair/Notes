# 希尔排序

希尔排序是插入排序的一种改进版本。

### 性能分析

希尔排序的最好时间复杂度为 O(n) ；最坏时间复杂度和平均时间复杂度都随着步长的不同而不同。

已知最优的最坏时间复杂度是根据 Sedgewick 提出的序列 {1,5,19,41,109……} 得出的 O(n^(4/3))，其平均时间复杂度为 O(n^(7/6))。

### 适用场景

使用 Sedgewick 提出的步长序列实现的希尔排序比插入排序要快，甚至在小规模数组中比快速排序和堆排序还要快，但在涉及到大规模数据时其性能还是不如快排。

### 特点

- 不稳定
- 空间复杂度为 O(1)

### 排序过程

插入排序每次只能将数据移动一位，如果数据集中的元素跟其正确的位置距离太远的话，就需要更多次的的移位操作才能将其放在正确位置。

假设有一个很小的数据在一个已按升序排好序的数组的末端。如果使用插入排序，可能会进行 n 次的比较和交换才能将该数据移至正确位置。而希尔排序会用较大的步长（gap）移动数据，所以小数据只需进行少数比较和交换即可到正确位置。

我们通过一个例子来理解整个排序过程。

假设需要将数组 [64, 20, 50, 33, 72, 10, 23, -1, 4] 进行希尔排序。

我们将数组的元素个数除以 2，得到步长：

```
n = floor(9/2) = 4
```

接下来我们创建 n 个子数组，在每个子数组中，子数组中的元素间隔 n 个位置。在这个例子中需要创建 4 个子数组：

```
sublist 0:  [ 64, xx, xx, xx, 72, xx, xx, xx, 4  ]
sublist 1:  [ xx, 20, xx, xx, xx, 10, xx, xx, xx ]
sublist 2:  [ xx, xx, 50, xx, xx, xx, 23, xx, xx ]
sublist 3:  [ xx, xx, xx, 33, xx, xx, xx, -1, xx ]
```

我们从原始数组的第一位开始，按照步长 4，分别取出 64、73、4 加入 `sublist 0`；

从第二开始，分别取出 20、10 加入 `sublist 1`，以此类推。

> 实际上我们并不是真的创建子数组，而是直接在原数组中进行操作，因此在上面的子数组中，将其它位置使用 xx 来代表。

接下来，使用插入排序对每个子数组进行排序：

```
sublist 0:  [ 4, xx, xx, xx, 64, xx, xx, xx, 72 ]
sublist 1:  [ xx, 10, xx, xx, xx, 20, xx, xx, xx ]
sublist 2:  [ xx, xx, 23, xx, xx, xx, 50, xx, xx ]
sublist 3:  [ xx, xx, xx, -1, xx, xx, xx, 33, xx ]
```

实际上原数组就变成了：

```
[ 4, 10, 23, -1, 64, 20, 50, 33, 72 ]
```

到此，一轮操作就完成了，接下来我们使用同样的方法进行后续操作。

将步长 4 除以 2 得到新的步长：

```
n = floor(4/2) = 2
```

然后创建 2 个子数组：

```
sublist 0:  [  4, xx, 23, xx, 64, xx, 50, xx, 72 ]
sublist 1:  [ xx, 10, xx, -1, xx, 20, xx, 33, xx ]
```

对每个子数组使用插入排序：

```
sublist 0:  [  4, xx, 23, xx, 50, xx, 64, xx, 72 ]
sublist 1:  [ xx, -1, xx, 10, xx, 20, xx, 33, xx ]
```

现在原数组变成了：

```
[ 4, -1, 23, 10, 50, 20, 64, 33, 72 ]
```

是不是看起来有序很多了？

接下来我们再将步长 2 除以 2，得到新的步长：

```
n = floor(2/2) = 1
```

步长为 1 意味着我们只有一个子数组，即原数组，然后使用插入排序：

```
[ -1, 4, 10, 20, 23, 33, 50, 64, 72 ]
```

这就是整个希尔排序过程。

**总结：**

希尔排序实际上是通过使用步长算法，快速将偏移正确位置很远的元素调整到其正确位置。多次调整以后，数组中的元素已经大致有序，在这种情况下插排的效率很高，可以很快地完成剩余的排序工作。

![ShellSort_01](ShellSort_01.gif)


### 实现代码

```swift
public func insertionSort(_ list: inout [Int], start: Int, gap: Int) {
  for i in stride(from: (start + gap), to: list.count, by: gap) {
    let currentValue = list[i]
    var pos = i
    while pos >= gap && list[pos - gap] > currentValue {
      list[pos] = list[pos - gap]
      pos -= gap
    }
    list[pos] = currentValue
  }
}

public func shellSort(_ list: [Int]) -> [Int] {
    guard list.count > 1 else { return list }
    
    var newList = list
    var sublistCount = newList.count / 2
    
    while sublistCount > 0 {
        for pos in 0..<sublistCount {
            insertionSort(&newList, start: pos, gap: sublistCount)
        }
        sublistCount = sublistCount / 2
    }
    
    return newList
}
```




参考链接：

- [Wikipedia: ShellSort](https://en.wikipedia.org/wiki/Shellsort)
- [维基百科：希尔排序](https://zh.wikipedia.org/wiki/%E5%B8%8C%E5%B0%94%E6%8E%92%E5%BA%8F)