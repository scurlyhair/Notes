# 二分查找

二分查找（Binary search）又称折半查找，用于**有序**数组。

时间复杂度为 O(log n)。 

空间复杂度为 O(n)

### 实现过程

假设待搜索数组是有小到大排列的。

将目标值与中位元素比较。

- 如果等于中位元素则返回；
- 如果小于中位元素就继续取前半部分的中位元素进行比较；
- 如果大于中位元素就继续取后半部分的中位元素进行比较。

就这样递归直到某一步数组为空，说明没有找到目标值。


### 实现代码

通常，因为递归需要调用很多层函数，所以将其转换成迭代可以将效率提高。

下面是迭代版本的实现过程：

```swift
func binarySearch<T: Comparable>(_ a: [T], key: T) -> Int {
    var lowerBound = 0
    var upperBound = a.count
    while lowerBound < upperBound {
        let midIndex = lowerBound + (upperBound - lowerBound) / 2
        if a[midIndex] == key {
            return midIndex
        } else if a[midIndex] < key {
            lowerBound = midIndex + 1
        } else {
            upperBound = midIndex
        }
    }
    return -1
}
```

