# 关键字

### @Environment

`@Environment` 是一个属性转换器（PropertyWraper），借由 `KeyPath` 进行环境变量的读写：

```swift
// 读取
@Environment(\.layoutDirection) var direction

// 修改
Text("")
    .environment(\.layoutDirection, .leftToRight)
```

你可以在这里查看所有内置的 `EnvironmentValues`：

[https://developer.apple.com/documentation/swiftui/environmentvalues](https://developer.apple.com/documentation/swiftui/environmentvalues)

当然我们也可以自定义一些 `EnvironmentValues`：

```swift
struct Custom {
    
}

struct CustomKey: EnvironmentKey {
    static let defaultValue: Custom = Custom()
}

extension EnvironmentValues {
    var customKey: Custom {
        get {
            return self[CustomKey.self]
        }
        set {
            self[CustomKey.self] = newValue
        }
    }
}
```

### @EnvironmentObject

借助于 `@EnvironmentObject` 我们可以将自定义对象添加到环境中，并在任意 View 中进行读写。可以简单地将它看做是全局的 `ObservableObject`，值改变时会触发相关 View 重新渲染。

Environment Object 必须保证在使用之前被添加，否则程序将 Crash，因此一般在根视图中将其添加：

```swift
class UserSettings: ObservableObject {
    @Published var score = 0
}

var settings = UserSettings() 

let content = ContentView().environmentObject(settings)
window.rootViewController = UIHostingController(rootView:  root)
```

读写：

```swift
@EnvironmentObject var settings: UserSettings
```


值得注意的是：

**在编写代码的时候，需要给 Preview 也提供相应的 Environment Object：**

```swift
ContentView().environmentObject(UserSettings())
```

### @State

SwiftUI 中的 View 是结构体，而结构体是值类型的，在程序运行中，可能会被多次销毁和创建。 `@State` 修饰符会把修饰的属性交给 SwiftUI 进行管理，在销毁和创建的时候不会丢失。

`@State` 一般用于修饰一些诸如 String 或者 Int 的简单类型，而且不应该在多个 View 之间进行共享，因此苹果建议使用它来修饰私有属性：

```swift
@State private var username = ""
```

如果你希望在多视图中共享数据，最好使用 `@ObservedObject ` 或者 `@EnvironmentObject ` 




