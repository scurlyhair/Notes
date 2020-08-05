# Swift 关键字

### defer

使用 defer 修饰的闭包会在当前 scope 执行退出之后被调用。

一般会有一下几个应用场景：

1. 被用于资源释放或销毁，在资源初始化的地方使用 defer 进行释放，以免后期遗忘。
2. 在有多个返回情况需要统一处理时，使用 defer 可以让我们在 return 后执行相关代码。

```swift
func operateOnFile(descriptor: Int32) {
    let fileHandle = FileHandle(fileDescriptor: descriptor)
    defer { fileHandle.closeFile() }
    let data = fileHandle.readDataToEndOfFile()

    if /* onlyRead */ { return }
    
    let shouldWrite = /* 是否需要写文件 */
    guard shouldWrite else { return }
    
    fileHandle.seekToEndOfFile()
    fileHandle.write(someData)
}
```

defer 会在当前 **scope** 退出时候被调用，并非在当前函数退出时调用，这点要注意。比如 `if`/`guard`/`for`/`try` 等语句。

```swift
func test() {
    if 1 == 1 {
        print("1")
        defer {
            print("defer block in if scope executed!")
        }
        print("2")
    }

    print("3")
    defer {
        print("defer block executed!")
    }

    print("4")
}

/** 会打印：
 1
 2
 defer block in if scope executed!
 3
 4
 defer block executed!
 */
```
