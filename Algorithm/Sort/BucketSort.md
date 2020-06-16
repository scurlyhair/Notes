# 桶排序

桶排序（Bucket sort）是一种线性非比较类的排序方法。

### 性能分析

桶排序的最优时间复杂度 O(n)、最坏时间复杂度 O(n^2)、平均时间复杂度是 O(n + k)。

### 适用场景

### 特点

- 稳定
- 最佳空间复杂度为 O(n)

### 排序过程

![BucketSort_01](BucketSort_01.png)

![BucketSort_02](BucketSort_02.png)

1. 设置一个定长的数组作为桶
2. 遍历待排序数组，并且把项目一个一个放到对应的桶中
3. 将所有非空的桶进行内部排序
4. 依次将桶中的元素放回数组

### 实现代码

```swift
public func bucketSort<T>(_ elements: [T], distributor: Distributor, sorter: Sorter, buckets: [Bucket<T>]) -> [T] {
    precondition(allPositiveNumbers(elements))
    precondition(enoughSpaceInBuckets(buckets, elements: elements))

    var bucketsCopy = buckets
    for elem in elements {
        distributor.distribute(elem, buckets: &bucketsCopy)
    }

    var results = [T]()

    for bucket in bucketsCopy {
        results += bucket.sort(sorter)
    }

    return results
}

private func allPositiveNumbers<T: Sortable>(_ array: [T]) -> Bool {
    return array.filter { $0.toInt() >= 0 }.count > 0
}

private func enoughSpaceInBuckets<T>(_ buckets: [Bucket<T>], elements: [T]) -> Bool {
    let maximumValue = elements.max()?.toInt()
    let totalCapacity = buckets.count * (buckets.first?.capacity)!

    guard let max = maximumValue else {
        return false
    }
    
    return totalCapacity >= max
}

//////////////////////////////////////
// MARK: Distributor
//////////////////////////////////////
public protocol Distributor {
    func distribute<T>(_ element: T, buckets: inout [Bucket<T>])
}

/*
 * An example of a simple distribution function that send every elements to
 * the bucket representing the range in which it fits.An
 *
 * If the range of values to sort is 0..<49 i.e, there could be 5 buckets of capacity = 10
 * So every element will be classified by the ranges:
 *
 * -  0 ..< 10
 * - 10 ..< 20
 * - 20 ..< 30
 * - 30 ..< 40
 * - 40 ..< 50
 *
 * By following the formula: element / capacity = #ofBucket
 */
public struct RangeDistributor: Distributor {

    public init() {}

    public func distribute<T>(_ element: T, buckets: inout [Bucket<T>]) {
        let value = element.toInt()
        let bucketCapacity = buckets.first!.capacity

        let bucketIndex = value / bucketCapacity
        buckets[bucketIndex].add(element)
    }
}

//////////////////////////////////////
// MARK: Sortable
//////////////////////////////////////
public protocol IntConvertible {
    func toInt() -> Int
}

public protocol Sortable: IntConvertible, Comparable {
}

//////////////////////////////////////
// MARK: Sorter
//////////////////////////////////////
public protocol Sorter {
    func sort<T: Sortable>(_ items: [T]) -> [T]
}

public struct InsertionSorter: Sorter {

    public init() {}

    public func sort<T: Sortable>(_ items: [T]) -> [T] {
        var results = items
        for i in 0 ..< results.count {
            var j = i
            while j > 0 && results[j-1] > results[j] {

                let auxiliar = results[j-1]
                results[j-1] = results[j]
                results[j] = auxiliar

                j -= 1
            }
        }
        return results
    }
}

//////////////////////////////////////
// MARK: Bucket
//////////////////////////////////////
public struct Bucket<T: Sortable> {
    var elements: [T]
    let capacity: Int

    public init(capacity: Int) {
        self.capacity = capacity
        elements = [T]()
    }

    public mutating func add(_ item: T) {
        if elements.count < capacity {
            elements.append(item)
        }
    }

    public func sort(_ algorithm: Sorter) -> [T] {
        return algorithm.sort(elements)
    }
}
```

参考链接：

- [Wikipeida: Bucket sort](https://en.wikipedia.org/wiki/Bucket_sort)
- [https://github.com/raywenderlich/swift-algorithm-club/tree/master/Bucket%20Sort](https://github.com/raywenderlich/swift-algorithm-club/tree/master/Bucket%20Sort)