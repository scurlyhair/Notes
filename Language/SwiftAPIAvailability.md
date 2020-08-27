# API 可用性

## @available

`@available` 用于标识某个 API 以明确其可用信息，比如“this API is deprecated in macOS 10.15” 或者 “this API requires Swift 5.1 or higher”。

`@available` 标识可以用来对 swift 中的大部分对象进行描述，包括顶层函数、常量、变量、结构体、类、枚举、协议、构造器、析构器、方法、属性、下标等。

> `@available` 标识不能用于操作符(+/-...)和关联类型(associatedtype)。

### 平台可用性

`@available` 提供了两种方式来对 API 的可用性进行描述：

- 速记法：列举出最低支持的平台和版本。
- 扩展法：可以对某个具体的平台版本兼容性提供细节信息。

**速记法**

```swift
// 速记法
@available(platform version , platform version ..., *)
- platform: iOS, macOS/OSX, macCatalyst, tvOS, watchOS 或者扩展类 macOSApplicationExtension
- version: 版本号可以由一个、两个、或三个数组成，中间用 `.` 分割，分别代表主版本号、次版本号、修订版本号。
- 最后一位的 `*` 代表其他平台版本，是必须项，为了兼容未来可能的新平台。


// 示例
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
```

在标识接口的平台可用性时，使用速记法非常便捷。但如果你想提供更多信息，比如 API 废弃的时间和原因，或者替代接口是什么，此时可以使用扩展法来声明接口的可用性。

**扩展法**

```swift
// 扩展法
// With introduced, deprecated, and/or obsoleted
@available(platform | *
          , introduced: version , deprecated: version , obsoleted: version
          , renamed: "..."
          , message: "...")

// With unavailable
@available(platform | *, unavailable , renamed: "..." , message: "...")
- platform: 同上，或者使用 `*` 代表所有平台。
- introduced: version 引入时的平台版本号
- deprecated: version 开始提示废弃警告的平台版本号
- obsoleted: version 开始提示编译错误的平台版本号
- unavailable 将 API 标识为不可用，在使用是会提示编译错误
- renamed 提供重命名后的函数名，会有 "fix- it" 的提醒
- message 警告或者错误的消息提示
```

跟速记法不同的是，扩展法的一条语句只能用来描述一个平台版本，如果需要对多个平台版本进行标记，则需要多条语句：

```swift
@available(iOS 13, *)
@available(tvOS, unavailable)
@available(macCatalyst, unavailable)
func handleShakeGesture() { … }
```

**标记 swift 版本**

标记 swift 版本时，最后面不需要添加 `*`。

```swift
// 标记 swift 版本
@available(swift version)

// 示例
import Foundation

@available(swift 5.1)
@available(iOS 13.0, macOS 10.15, *)
@propertyWrapper
struct WebSocketed<Value: LosslessStringConvertible> {
    private var value: Value
    var wrappedValue: URLSessionWebSocketTask.Message {
        get { .string(value) }
        set {
            if case let .string(description) = newValue {
                value = Value(description)
            }
        }
    }
}

```

## #available

`#available` 可以跟 if、guard、while 等条件语句结合来进行运行时判断，但是不能用于判断 swift 版本。

```swift
if | guard | while #available(platform version , platform version ..., *) …
```

多个条件可以在判断语句中使用 `,` 分割，但不支持 `&&` 或 `||` 等逻辑操作符。

```swift
// 应用示例
@available(iOS 13.0, *)
final class CustomCompositionalLayout: UICollectionViewCompositionalLayout { … }

func createLayout() -> UICollectionViewLayout {
    if #available(iOS 13, *) {
        return CustomCompositionalLayout()
    } else {
        return UICollectionViewFlowLayout()
    }
}
```


参考链接：

- [https://nshipster.com/available/](https://nshipster.com/available/)