# 动态规划

动态规划（Dynamic programming）简称 DP，通过把原问题分解为相对简单的子问题的方式来求解复杂问题。

动态规划用于查找有很多重叠子问题和最优子结构的情况。它将问题重新组合成子问题。为了避免多次解决这些子问题，它的结果都逐渐被计算并保存，从简单的问题直到整个问题都被解决。

下面我们通过一个例子来理解动态规划的核心思想。

### 自顶向下的递归

Q：求解斐波那契数列中索引为 n 的值。

我们可以使用递归来求解：

```swift
func fibonacciNumber(_ index: Int) -> Int {
    if index == 0 { return 0 }
    if index == 1 { return 1 }
    return fibonacciNumber(index - 1) + fibonacciNumber(index - 2)
}
```

看起来没有毛病，但是这种方案其实效率很低，让我们来分析一下实际运算过程中发生了什么。

假设 n = 20，画出递归树：

![DynamicProgramming_01](DynamicProgramming_01.jpg)

> PS：但凡遇到需要递归的问题，最好都画出递归树，这对你分析算法的复杂度，寻找算法低效的原因都有巨大帮助。

可以看到这种解法的时间复杂度是 O(2^n)。

对递归树进行分析可知，算法中存在大量的重复运算。

因此我们可以对这些重复运算的结果进行缓存，需要的时候直接读取。

```swift
var cacheArray: [Int] = [0, 1]

func fibonacciNumber(_ index: Int) -> Int {
    if index == 0 { return 0 }
    if index == 1 { return 1 }
    
    cacheArray = Array(repeating: 0, count: index + 1)
    if cacheArray[index] != 0 { return cacheArray[index] }
    cacheArray[index] = fibonacciNumber(index - 1) + fibonacciNumber(index - 2)
    return cacheArray[index]
}
```

这样我们就实现了对重复计算的的剪枝。

![DynamicProgramming_02](DynamicProgramming_02.jpg)

此时时间复杂度为 O(n)，空间复杂度为 O(n)。

这就是动态规划的核心：**将复杂问题分解为许多简单问题，对简单问题的结果进行缓存，以提高求解效率，最终求解出整体答案。**

有了上面的基础，我们完全可以从最小子问题一步一步向上求解得到最终结果。

### 自底向上的迭代

使用迭代的方式进行求解。

```swift
func fibonacciNumber(_ index: Int) -> Int {
    var cacheArray = Array(repeating: 0, count: index + 1)
    cacheArray[0] = 0
    cacheArray[1] = 1
    
    for i in 2...index {
        cacheArray[i] = cacheArray[i - 1] + cacheArray[i - 2]
    }
    return cacheArray[index]
}
```

### 动态规划

动态规划的核心元素有两个：

- 缓存表（dp）
- 状态转移方程

**缓存表**

缓存表用来记录子问题的解，并不必拘泥于数组。比如上面的缓存表完全可以优化为 3 个变量 `preA`、`preB` 和 `sum`：

```swift
func fibonacci(_ index: Int) -> Int {
    if index == 0 { return 0 }
    if index == 1 { return 1 }
    var preA = 0, preB = 1, sum = 1
    for _ in 2...index {
        sum = preA + preB
        preA = preB
        preB = sum
    }
    return sum
}
```

这样空间复杂度被优化为 O(1)。

**状态转移方程**

状态转移方程用来描述子问题是之间的组合关系。

比如案例中的状态转移方程：

```
f(0) = 0
f(1) = 1
f(n) = f(n-1) + f(n-2)
```

实际上，状态转移方程代表了所有子问题的穷举求解方式，而缓存表将必要的结果记录，优化穷举。

**一般流程**

求解动态规划问题的一般性流程：

1. 状态定义（设计缓存表 dp）
2. 列出状态转移方程
3. 分析边界条件

状态定义最重要的是思路的切入点，即如何对复杂问题进行拆解。第一步完成之后，后面就迎刃而解了。

下面我们通过几个案例体会这种拆解思维。

### 案例一：爬楼梯

[70. 爬楼梯](https://leetcode-cn.com/problems/climbing-stairs/)：

假设你正在爬楼梯。需要 n 阶你才能到达楼顶。

每次你可以爬 1 或 2 个台阶。你有多少种不同的方法可以爬到楼顶呢？

注意：给定 n 是一个正整数。

示例：

```
输入： 2
输出： 2
解释： 有两种方法可以爬到楼顶。
1.  1 阶 + 1 阶
2.  2 阶
```

**解答**

状态定义：

dp[i] 代表爬到第 i 级台阶的方案数。

爬到第 i 级台阶的方式有两种：最后一步可能跨了一级台阶，也可能跨了两级台阶。它意味着爬到第 i 级台阶的方案数是爬到第 i - 1 级台阶的方案数和爬到第 i - 2 级台阶的方案数的和。

列出状态转移方程：

```
f(n) = f(n - 1) + f(n - 2)
```

考虑边界条件：

- 从 0 级到 0 级，有一种解决方案 f(0) = 1，即不爬
- 从 0 级到 1 级，有一种解决方案 f(1) = 1，即 1
- 从 0 级到 2 级，有 2 种方案 f(2) = 2，即（1, 1)、2
- 从 0 级到 3 级，有 3 种方案 f(3) = 3，即（1, 1, 1）、（1, 2）、（2, 1）

可以看到从第 2 级开始已经可以满足状态转移方程式。

显然，这个问题最终抽象为类似我们上面的案例：斐波那契数列。只不过边界取值是从 1 开始。

```swift
func climbStairs(_ n: Int) -> Int {
    if n == 0 { return 1 }
    if n == 1 { return 1 }
    var preA = 1, preB = 1, sum = 2
    for _ in 2...n {
        sum = preA + preB
        preA = preB
        preB = sum
    }
    return sum
}
```

### 案例二：连续子数组的最大和

[剑指 Offer 42. 连续子数组的最大和](https://leetcode-cn.com/problems/lian-xu-zi-shu-zu-de-zui-da-he-lcof/)

输入一个整型数组，数组里有正数也有负数。数组中的一个或连续多个整数组成一个子数组。求所有子数组的和的最大值。

要求时间复杂度为O(n)。

示例：

```
输入: nums = [-2,1,-3,4,-1,2,1,-5,4]
输出: 6
解释: 连续子数组 [4,-1,2,1] 的和最大，为 6。
```

**解答**

状态定义：

设 dp[i] 代表以元素 numbers[i] 结尾的连续子数组的最大和。

dp[i] 可以看做 dp[i-1] + numbers[i]，如果 dp[i-1] <= 0 时，会对 dp[i] 起负作用。

列出状态转义方程：

```
当 dp[i-1] <= 0， dp[i] = numbers[i]
当 dp[i-1] > 0， dp[i] = dp[i-1] + numbers[i]
```

分析边界：

dp[0] = numbers[0]

```swift
func maxSum(_ numbers: [Int]) -> Int? {
    if numbers.count == 0 { return nil }
    if numbers.count == 1 { return numbers.last! }
    
    var cache = Array(repeating: numbers.first!, count: numbers.count)
    var maxValue = numbers[0]
    for i in 1..<numbers.count {
        if cache[i - 1] <= 0 {
            cache[i] = numbers[i]
        } else {
            cache[i] = cache[i - 1] + numbers[i]
        }
        maxValue = max(maxValue, cache[i])
    }
    return maxValue
}
```

优化缓存表：

```swift
func maxSum(_ numbers: [Int]) -> Int? {
    if numbers.count == 0 { return nil }
    if numbers.count == 1 { return numbers.last! }
    
    var pre = numbers.first!, current = 0
    var maxValue = numbers[0]
    for i in 1..<numbers.count {
        if pre <= 0 {
            current = numbers[i]
        } else {
            current = pre + numbers[i]
        }
        pre = current
        maxValue = max(maxValue, current)
    }
    return maxValue
}
```


### 背包问题













参考链接：

- [维基百科：动态规划](https://zh.wikipedia.org/wiki/%E5%8A%A8%E6%80%81%E8%A7%84%E5%88%92)
- [https://labuladong.gitbook.io/algo/dong-tai-gui-hua-xi-lie/dong-tai-gui-hua-xiang-jie-jin-jie](https://labuladong.gitbook.io/algo/dong-tai-gui-hua-xi-lie/dong-tai-gui-hua-xiang-jie-jin-jie)
- [https://leetcode-cn.com/problems/coin-lcci/solution/bei-bao-jiu-jiang-ge-ren-yi-jian-da-jia-fen-xiang-/](https://leetcode-cn.com/problems/coin-lcci/solution/bei-bao-jiu-jiang-ge-ren-yi-jian-da-jia-fen-xiang-/)