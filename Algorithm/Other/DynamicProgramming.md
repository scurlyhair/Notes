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

- 缓存表
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

### 爬楼梯

我们来看 leetcode 中的爬楼梯问题。

[70 爬楼梯](https://leetcode-cn.com/problems/climbing-stairs/)：

假设你正在爬楼梯。需要 n 阶你才能到达楼顶。

每次你可以爬 1 或 2 个台阶。你有多少种不同的方法可以爬到楼顶呢？

注意：给定 n 是一个正整数。

**求解**

我们用 f(x) 表示爬到第 xx 级台阶的方案数，考虑最后一步可能跨了一级台阶，也可能跨了两级台阶，它意味着爬到第 x 级台阶的方案数是爬到第 x - 1 级台阶的方案数和爬到第 x - 2 级台阶的方案数的和。

很好理解，因为每次只能爬 1 级或 2 级，所以 f(x) 只能从 f(x - 1) 和 f(x - 2) 转移过来，而这里要统计方案总数，我们就需要对这两项的贡献求和。

所以我们得到如下状态转移方程：

f(x) = f(x - 1) + f(x - 2)

下面来考虑边界条件。

- 从 0 级到 0 级，有一种解决方案 f(0) = 1，即不爬
- 从 0 级到 1 级，有一种解决方案 f(1) = 1，即 1
- 从 0 级到 2 级，有 2 种方案 f(2) = 2，即（1, 1)、2
- 从 0 级到 3 级，有 3 种方案 f(3) = 3，即（1, 1, 1）、（1, 2）、（2, 1）

可以看到从第 2 级开始已经可以满足状态转移方程式。

显然，这个问题最终抽象为类似我们上面的案例：斐波那契数列。只不过边界是从 1 开始。

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


### 最优子结构

动态规划常被用于求最值。因此要求问题具有最优子结构。















参考链接：

- [维基百科：动态规划](https://zh.wikipedia.org/wiki/%E5%8A%A8%E6%80%81%E8%A7%84%E5%88%92)
- [https://labuladong.gitbook.io/algo/dong-tai-gui-hua-xi-lie/dong-tai-gui-hua-xiang-jie-jin-jie](https://labuladong.gitbook.io/algo/dong-tai-gui-hua-xi-lie/dong-tai-gui-hua-xiang-jie-jin-jie)