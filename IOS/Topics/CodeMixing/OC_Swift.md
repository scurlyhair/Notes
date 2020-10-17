# OC 和 Swift 混编

## 在 OC 中使用 Swift

1. 在 xcode 中添加 Swift 文件并**编译**后系统会自动生成一个 `xxx-Swift.h` 
2. 在需要使用 Swift 代码的 .m 文件中导入该头文件 

### 让 swift 代码兼容 oc

要在 oc 中使用 swift 需要对 swift 代码有一些要求。

#### 1. 定义

1. 只能使用 `class` 类型
2. 必须继承 `NSObject`
3. 必须使用 `@objc` 修饰此类型以及想要暴露给 oc 的属性或方法（可以使用 `@objectMembers` 关键字来修饰类型，这样，类型中的属性和非私有方法都会被暴露出来）

```swift
@objcMembers class TestClass: NSObject {
    var name: String?
    func doSomething() {
    }
}
```

#### 2. 数据类型

```swift
@objcMembers class TestClass: NSObject {
    var string: String = ""
    var stringOpt: String?
    var number: NSNumber = 0
    var numberOpt: NSNumber?
    var double: Double = 0 
    var doubleOpt: Double? // 不兼容 ⚠️
    var int: Int = 0 
    var intOpt: Int? // 不兼容 ⚠️
    var dic: Dictionary<String, Any> = [:]
    var dicOpt: Dictionary<String, Any>?
    var array: Array<Int> = []
    var arrayOpt: Array<Int>?
    func doSomething() {
        
    }
}

// 编译后
SWIFT_CLASS("_TtC9广企通9TestClass")
@interface TestClass : NSObject
@property (nonatomic, copy) NSString * _Nonnull string;
@property (nonatomic, copy) NSString * _Nullable stringOpt;
@property (nonatomic, strong) NSNumber * _Nonnull number;
@property (nonatomic, strong) NSNumber * _Nullable numberOpt;
@property (nonatomic, getter=double, setter=setDouble:) double double_;
@property (nonatomic, getter=int, setter=setInt:) NSInteger int_;
@property (nonatomic, copy) NSDictionary<NSString *, id> * _Nonnull dic;
@property (nonatomic, copy) NSDictionary<NSString *, id> * _Nullable dicOpt;
@property (nonatomic, copy) NSArray<NSNumber *> * _Nonnull array;
@property (nonatomic, copy) NSArray<NSNumber *> * _Nullable arrayOpt;
- (void)doSomething;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end
```

#### 3. 枚举

枚举需要使用 `@objc` 修饰并显式指定枚举类型为 `Int`

```swift
@objc enum TestEnum: Int {
    case typeA
}

// 编译后
typedef SWIFT_ENUM(NSInteger, TestEnum, closed) {
  TestEnumTypeA = 0,
};
```

#### 4. 异常抛出

swift 抛出的错误通过继承 `CustomNSError` 来被 oc 正确解析

```swift
/// 自定义错误
enum CommonCustomError: CustomNSError {
    /// 自定义错误消息
    case message(desc: String)

    /// 错误信息 user info
    var errorUserInfo: [String: Any] {
        switch self {
        case let .message(desc):
            return [NSLocalizedDescriptionKey: desc]
        }
    }
}

// 在 oc 中从 localizedDescription 变量中读取错误信息
error.localizedDescription
```

## 在 Swift 中使用OC

需要创建一个 `{project_name}-Bridging-Header.h` 文件，在此文件中导入所需的 OC 头文件

```oc
//MARK: - 第三方库
#import "Masonry.h"

// MARK: - 项目文件
#import "BaseViewController.h"
```

在 Target -> General -> SwiftCompiler - General 中设置头文件路径

```
// 比如 {project_name}-Bridging-Header.h 放在根目录的 Config 文件夹下面
$(SRCROOT)/Config/{project_name}-Bridging-Header.h
```