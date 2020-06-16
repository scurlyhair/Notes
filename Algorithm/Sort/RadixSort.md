# 基数排序

基数排序（Radix sort）是一种非比较型整数排序算法，其原理是将整数按位数切割成不同的数字，然后按每个位数分别比较。由于整数也可以表达字符串（比如名字或日期）和特定格式的浮点数，所以基数排序也不是只能使用于整数。

### 性能分析

基数排序的最优时间复杂度、最坏时间复杂度、平均时间复杂度都是 O(n * k)。

### 适用场景

### 特点

- 稳定
- 空间复杂度为 O(n + k)

### 排序过程

![RadixSort_01](RadixSort_01.gif)

将所有待比较数值（正整数）统一为同样的数位长度，数位较短的数前面补零。然后，从最低位开始，依次进行一次排序。这样从最低位排序一直到最高位排序完成以后，数列就变成一个有序序列。

### 实现代码

下面是一种不支持负数元素的实现：

```swift
func radixSort(_ array: inout [Int] ) {
  let radix = 10  //Here we define our radix to be 10
  var done = false
  var index: Int
  var digit = 1  //Which digit are we on?
  while !done {  //While our  sorting is not completed
    done = true  //Assume it is done for now
    var buckets: [[Int]] = []  //Our sorting subroutine is bucket sort, so let us predefine our buckets
    for _ in 1...radix {
      buckets.append([])
    }

    for number in array {
      index = number / digit  //Which bucket will we access?
      buckets[index % radix].append(number)
      if done && index > 0 {  //If we arent done, continue to finish, otherwise we are done
        done = false
      }
    }

    var i = 0

    for j in 0..<radix {
      let bucket = buckets[j]
      for number in bucket {
        array[i] = number
        i += 1
      }
    }

    digit *= radix  //Move to the next digit
  }
}
```


参考链接：

- [维基百科：基数排序](https://zh.wikipedia.org/wiki/%E5%9F%BA%E6%95%B0%E6%8E%92%E5%BA%8F)
- [十大经典排序算法（动图演示）](https://www.cnblogs.com/onepixel/p/7674659.html)