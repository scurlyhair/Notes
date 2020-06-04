# 栈

堆栈（stack）又称为栈或堆叠，只允许在其顶部进行加入和移除运算。因而按照后进先出（LIFO: Last In First Out）的原理运作。

借助数组我们可以很容易地实现一个栈。

```swift
public struct Stack<T> {
  fileprivate var array = [T]()

  public var isEmpty: Bool {
    return array.isEmpty
  }

  public var count: Int {
    return array.count
  }

  public mutating func push(_ element: T) {
    array.append(element)
  }

  public mutating func pop() -> T? {
    return array.popLast()
  }

  public var top: T? {
    return array.last
  }
}
```

我们可以很直观的看到，这个栈的 `push` 和 `pop` 操作时间复杂度都为 O(1)。

### 应用

**函数栈**

当 A 函数调用 B 函数的时候，会向 B 传递参数，然后执行 B 函数，完成之后将结果返回到 A 函数中，继续执行 A 函数的其他语句。而这个机制就是通过栈来实现的。

当发生函数调用的时候，CPU 都会对参数和返回值进行入栈操作，函数执行完成进行出栈操作。由于栈空间并不是无限大的，当出现很多层的函数调用（比如递归）时，就有可能会导致栈溢出。

**括号匹配的检验**

括号都是成对出现的，比如“()”“[]”“{}”“<>”这些成对出现的符号。具体处理的方法就是：凡是遇到括号的前半部分，即把这个元素入栈，凡是遇到括号的后半部分就比对栈顶元素是否该元素相匹配，如果匹配，则前半部分出栈，否则就是匹配出错。

**数制转换**

将十进制的数转换为2-9的任意进制的数。我们都知道，通过求余法，可以将十进制数转换为其他进制，比如要转为八进制，将十进制数除以8，记录余数，然后继续将商除以8，一直到商等于0为止，最后将余数倒着写数来就可以了。比如100的八进制，100首先除以8商12余4,4首先进栈，然后12除以8商1余4，第二个余数4进栈，接着1除以8，商0余1，第三个余数1进栈，最后将三个余数出栈，就得到了100的八进制数144。

参考链接：

- [https://github.com/raywenderlich/swift-algorithm-club/tree/master/Stack](https://github.com/raywenderlich/swift-algorithm-club/tree/master/Stack)
- [数据结构(三)--栈](https://www.cnblogs.com/xiaoyouPrince/p/8082640.html)