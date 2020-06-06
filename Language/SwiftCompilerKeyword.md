# Swift 编译指令关键字

Swift 一些以 _@_ 开头的关键字用于给编译器标记一些特殊指令。

**@inline**

`@inline` 是函数内联指令，包括：

- `@inline(__always)` 如果可以的话，指示编译器始终内联方法
- `@inline(never)` 指示编译器永不内联方法

在编译阶段，编译器会进行一系列优化，包括速度优化和包体积优化。

通过函数内联，编译器将某个函数内部的执行语句直接编译成调用方的执行语句，这样可以显著提高性能，但如果此函数有多个调用者的话，就会让这部分代码被拷贝到多个地方，造成包体积变大。

例如：

```swift
func methodA() {
    methodB()
}

@inline(__always) func methodB() {
    print("hello world")
}
```
将会被优化成：

```swift
func methodA() {
    print("hello world")
}
```
另外， `@inline` 也可以用在一些重要函数的安全防护。因为进行内联的函数在安装包被逆向之后不会直接显示函数名而是一些汇编代码，这样可以让逆向过程变得更为复杂。

参考链接：

- [The Forbidden @inline Attribute in Swift](https://swiftrocks.com/the-forbidden-inline-attribute-in-swift)


**@discardableResult**

`@discardableResult` 关键字用来消除 _result unused_ 警告。

有些函数虽然有返回值，但其主要功能是完成它的边界效应。例如 Swift 数组中的：

```swift
@discardableResult mutating func removeLast() -> Element
```
在日常编码中，有一个很典型的应用：

```swift
@discardableResult
func getUsers(result: Result<[User], Error>) -> URLSessionTask {
    let url = URL(string: "https://example.com/api/users")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        // Handle a response
    }
    task.resume()
    
    return task
}
```

此方法主要完成获取 Users 的操作，同时返回的 `URLSessionTask` 也为其调用者提供了诸如 `cancel` 等操作的可能。

参考链接：

- [What is @discardableResult](https://sarunw.com/posts/what-is-discardableresult/)