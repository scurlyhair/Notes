# Swift
## 1 数据类型
### 整数

Swift 提供了8、16、32和64位的有符号和无符号整数类型。分别为 `Int8/Int16/Int32/Int64` 和 `UInt8/UInt16/UInt32/UInt64`。

一般来说，并不需要专门指定整数的长度。Swift 提供了一个特殊的整数类型 `Int`，长度与当前平台的原生字长相同：

- 在32位平台上，`Int` 和 `Int32` 长度相同。
- 在64位平台上，`Int` 和 `Int64` 长度相同。

UInt 同理。

### 浮点数

浮点类型比整数类型表示的范围更大，可以存储比 `Int` 类型更大或者更小的数字。Swift 提供了两种有符号浮点数类型：

- `Float` 表示32位浮点数。精度要求不高的话可以使用此类型。
- `Double` 表示64位浮点数。当需要存储很大或者很高精度的浮点数时请使用此类型。

>  `Double` 精确度很高，至少有15位数字，而 `Float` 只有6位数字。在两种类型都匹配的情况下，优先选择 `Double`。

### 元组
元组（tuples）把多个值组合成一个复合值。元组内的值可以是任意类型，并不要求是相同类型。
下面这个例子中，(404, "Not Found") 是一个描述 HTTP 状态码（HTTP status code）的元组。HTTP 状态码是当你请求网页的时候 web 服务器返回的一个特殊值。如果你请求的网页不存在就会返回一个 404 Not Found 状态码。

```swift
let http404Error = (404, "Not Found")
// http404Error 的类型是 (Int, String)，值是 (404, "Not Found")
```

可以通过下标来访问元组中的单个元素：

```swift
print("The status code is \(http404Error.0)")
// 输出“The status code is 404”
print("The status message is \(http404Error.1)")
// 输出“The status message is Not Found”
```

### 布尔类型

### 字符串
### String.Index 
由于swift 的 String 类型是基于 `Unicode` 标量建立的。而每一个 `Unicode` 标量占用的内存空间不确定，所以不能使用 `Int` 来作为索引。

### 类型安全和类型推断

Swift 是静态语言，在编译时期会进行类型检查。并标记错误。

如果没有显式地声明类型，Swift 将会根据变量的赋值情况进行类型推断。

```swift
let meaningOfLife = 42
// meaningOfLife 会被推测为 Int 类型

let pi = 3.14159
// pi 会被推测为 Double 类型
```

## 2 控制流
### switch 
在 Swift 里，`switch` 语句不会从上一个 `case` 分支跳转到下一个 `case` 分支中。相反，只要第一个匹配到的 `case` 分支完成了它需要执行的语句，整个 `switch` 代码块完成了它的执行。相比之下，C 语言要求你显式地插入 `break` 语句到每个 `case` 分支的末尾来阻止自动落入到下一个 `case` 分支中。Swift 的这种避免默认落入到下一个分支中的特性意味着它的 `switch` 功能要比 C 语言的更加清晰和可预测，可以避免无意识地执行多个 `case` 分支从而引发的错误。
如果你确实需要 C 风格的贯穿的特性，你可以在每个需要该特性的 `case` 分支中使用 `fallthrough` 关键字。下面的例子使用 `fallthrough` 来创建一个数字的描述语句。

```swift
let integerToDescribe = 5
var description = "The number \(integerToDescribe) is"
switch integerToDescribe {
case 2, 3, 5, 7, 11, 13, 17, 19:
    description += " a prime number, and also"
    fallthrough
default:
    description += " an integer."
}
print(description)
// 输出“The number 5 is a prime number, and also an integer.”
```

## 3 函数

在 Swift 中，函数是一等公民，可以作为其他函数的参数。

### 可变参数

一个可变参数`（variadic parameter）`可以接受零个或多个值。函数调用时，你可以用可变参数来指定函数参数可以被传入不确定数量的输入值。通过在变量类型名后面加入`（...）`的方式来定义可变参数。
可变参数的传入值在函数体中变为此类型的一个数组。例如，一个叫做 `numbers` 的 `Double...` 型可变参数，在函数体内可以当做一个叫 `numbers` 的 `[Double]` 型的数组常量。
下面的这个函数用来计算一组任意长度数字的 算术平均数`（arithmetic mean)`：

```swift
func arithmeticMean(_ numbers: Double...) -> Double {
    var total: Double = 0
    for number in numbers {
        total += number
    }
    return total / Double(numbers.count)
}
arithmeticMean(1, 2, 3, 4, 5)
// 返回 3.0, 是这 5 个数的平均数。
arithmeticMean(3, 8.25, 18.75)
// 返回 10.0, 是这 3 个数的平均数。
```
>  一个函数最多只能拥有一个可变参数。

## 4 枚举
### 枚举是一等公民
它拥有很多类所支持的特性。

- 计算属性
- 实例方法
- 构造函数
- 可扩展
- 可遵循协议
- 与 C 和 Objective-C 不同，Swift 的枚举成员在被创建时不会被赋予一个默认的整型值。

## 5 类和结构体

### 类和结构体的区别
- 继承允许一个类继承另一个类的特征
- 类型转换允许在运行时检查和解释一个类实例的类型
- 析构器允许一个类实例释放任何其所被分配的资源
- 引用计数允许对一个类的多次引用

### 恒等运算符
因为类是引用类型，所以多个常量和变量可能在幕后同时引用同一个类实例。（对于结构体和枚举来说，这并不成立。因为它们作为值类型，在被赋予到常量、变量或者传递到函数时，其值总是会被拷贝。）
判定两个常量或者变量是否引用同一个类实例有时很有用。为了达到这个目的，Swift 提供了两个恒等运算符：

- 相同`（===）`
- 不相同`（!==）`

使用这两个运算符检测两个常量或者变量是否引用了同一个实例：

```swift
if tenEighty === alsoTenEighty {
    print("tenEighty and alsoTenEighty refer to the same VideoMode instance.")
}
// 打印 "tenEighty and alsoTenEighty refer to the same VideoMode instance."
```

请注意，“相同”（用三个等号表示，`===`）与“等于”（用两个等号表示，`==`）的不同。“相同”表示两个类类型（class type）的常量或者变量引用同一个类实例。“等于”表示两个实例的值“相等”或“等价”，判定时要遵照设计者定义的评判标准。

## 6 属性

### 属性包装器

属性包装器在管理属性如何存储和定义属性的代码之间添加了一个分隔层。举例来说，如果你的属性需要线程安全性检查或者需要在数据库中存储它们的基本数据，那么必须给每个属性添加同样的逻辑代码。当使用属性包装器时，你只需在定义属性包装器时编写一次管理代码，然后应用到多个属性上来进行复用。

```swift
@propertyWrapper
struct TwelveOrLess {
    private var number: Int
    init() { self.number = 0 }
    var wrappedValue: Int {
        get { return number }
        set { number = min(newValue, 12) }
    }
}

struct SmallRectangle {
    @TwelveOrLess var height: Int
    @TwelveOrLess var width: Int
}

var rectangle = SmallRectangle()
print(rectangle.height)
// 打印 "0"

rectangle.height = 10
print(rectangle.height)
// 打印 "10"

rectangle.height = 24
print(rectangle.height)
// 打印 "12"
```

### 延迟加载

全局变量是延迟加载的。只有在第一次使用的时候才会去赋值。

### 通过闭包或函数设置属性的默认值

如果某个存储型属性的默认值需要一些自定义或设置，你可以使用闭包或全局函数为其提供定制的默认值。每当某个属性所在类型的新实例被构造时，对应的闭包或函数会被调用，而它们的返回值会当做默认值赋值给这个属性。

```swift
class SomeClass {
    let someProperty: SomeType = {
        // 在这个闭包中给 someProperty 创建一个默认值
        // someValue 必须和 SomeType 类型相同
        return someValue
    }()
}
```

> 注意闭包结尾的花括号后面接了一对空的小括号。这用来告诉 Swift 立即执行此闭包。如果你忽略了这对括号，相当于将闭包本身作为值赋值给了属性，而不是将闭包的返回值赋值给属性。

## 7 下标
下标可以定义在类、结构体和枚举中，是访问集合、列表或序列中元素的快捷方式。可以使用下标的索引，设置和获取值，而不需要再调用对应的存取方法。举例来说，用下标访问一个 `Array` 实例中的元素可以写作 `someArray[index]`，访问 `Dictionary` 实例中的元素可以写作 `someDictionary[key]`。
一个类型可以定义多个下标，通过不同索引类型进行对应的重载。下标不限于一维，你可以定义具有多个入参的下标满足自定s义类型的需求。
### 实例下标
`subscript(index: Int) -> Int`

```
struct TimesTable {
    let multiplier: Int
    subscript(index: Int) -> Int {
        return multiplier * index
    }
}
let threeTimesTable = TimesTable(multiplier: 3)
print("six times three is \(threeTimesTable[6])")

struct Matrix {
    let rows: Int, columns: Int
    var grid: [Double]
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: 0.0, count: rows * columns)
    }
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}
```
### 类型下标
正如上节所述，实例下标是在特定类型的一个实例上调用的下标。你也可以定义一种在这个类型自身上调用的下标。这种下标被称作类型下标。你可以通过在 `subscript` 关键字之前写下 `static` 关键字的方式来表示一个类型下标。类类型可以使用 `class` 关键字来代替 `static`，它允许子类重写父类中对那个下标的实现`static subscript(index: Int) -> Int`。下面的例子展示了如何定义和调用一个类型下标：

```swift
enum Planet: Int {
    case mercury = 1, venus, earth, mars, jupiter, saturn, uranus, neptune
    static subscript(n: Int) -> Planet {
        return Planet(rawValue: n)!
    }
}
let mars = Planet[4]
print(mars)
```


## 8 构造器
### 两段式构造过程

Swift 中类的构造过程包含两个阶段。第一个阶段，类中的每个存储型属性赋一个初始值。当每个存储型属性的初始值被赋值后，第二阶段开始，它给每个类一次机会，在新实例准备使用之前进一步自定义它们的存储型属性。
两段式构造过程的使用让构造过程更安全，同时在整个类层级结构中给予了每个类完全的灵活性。两段式构造过程可以防止属性值在初始化之前被访问，也可以防止属性被另外一个构造器意外地赋予不同的值。

> Swift 的两段式构造过程跟 `Objective-C` 中的构造过程类似。最主要的区别在于阶段 1，`Objective-C` 给每一个属性赋值 `0` 或空值（比如说 `0` 或 `nil`）。Swift 的构造流程则更加灵活，它允许你设置定制的初始值，并自如应对某些属性不能以 `0` 或 `nil` 作为合法默认值的情况。

阶段1

1. 类的某个指定构造器或便利构造器被调用。
2. 完成类的新实例内存的分配，但此时内存还没有被初始化。
3. 指定构造器确保其所在类引入的所有存储型属性都已赋初值。存储型属性所属的内存完成初始化。
4. 指定构造器切换到父类的构造器，对其存储属性完成相同的任务。
5. 这个过程沿着类的继承链一直往上执行，直到到达继承链的最顶部。
6. 当到达了继承链最顶部，而且继承链的最后一个类已确保所有的存储型属性都已经赋值，这个实例的内存被认为已经完全初始化。此时阶段 1 完成。

阶段2

1. 从继承链顶部往下，继承链中每个类的指定构造器都有机会进一步自定义实例。构造器此时可以访问 self、修改它的属性并调用实例方法等等。
2. 最终，继承链中任意的便利构造器有机会自定义实例和使用 self。

### 构造器的继承和重写

跟 Objective-C 中的子类不同，Swift 中的子类默认情况下不会继承父类的构造器。Swift 的这种机制可以防止一个父类的简单构造器被一个更精细的子类继承，而在用来创建子类时的新实例时没有完全或错误被初始化。

- 当你在编写一个和父类中**指定**构造器相匹配的子类构造器时，你实际上是在重写父类的这个指定构造器。因此，你必须在定义子类构造器时带上 `override` 修饰符。即使你重写的是系统自动提供的默认构造器，也需要带上 `override` 修饰符。

- 如果你编写了一个和父类**便利**构造器相匹配的子类构造器，由于子类不能直接调用父类的便利构造器（每个规则都在上文 类的构造器代理规则 有所描述），因此，严格意义上来讲，你的子类并未对一个父类构造器提供重写。最后的结果就是，你在子类中“重写”一个父类便利构造器时，不需要加 `override` 修饰符。

### 构造器的自动集成

如上所述，子类在默认情况下不会继承父类的构造器。但是如果满足特定条件，父类构造器是可以被自动继承的。事实上，这意味着对于许多常见场景你不必重写父类的构造器，并且可以在安全的情况下以最小的代价继承父类的构造器。

规则1：

如果子类没有定义任何指定构造器，它将自动继承父类所有的**指定**构造器。

规则2：

如果子类提供了所有父类**指定**构造器的实现——无论是通过规则 1 继承过来的，还是提供了自定义实现——它将自动继承父类所有的**便利**构造器。

> 子类可以将父类的指定构造器实现为便利构造器来满足规则 2。


### 可失败构造器

你可以在一个类，结构体或是枚举类型的定义中，添加一个或多个可失败构造器。其语法为在 `init` 关键字后面添加问号`（init?）`。

> 可失败构造器的参数名和参数类型，不能与其它非可失败构造器的参数名，及其参数类型相同。

```swift
struct Animal {
    let species: String
    init?(species: String) {
        if species.isEmpty {
            return nil
        }
        self.species = species
    }
}

let someCreature = Animal(species: "Giraffe")
// someCreature 的类型是 Animal? 而不是 Animal

if let giraffe = someCreature {
    print("An animal was initialized with a species of \(giraffe.species)")
}
// 打印“An animal was initialized with a species of Giraffe”

let anonymousCreature = Animal(species: "")
// anonymousCreature 的类型是 Animal?, 而不是 Animal

if anonymousCreature == nil {
    print("The anonymous creature could not be initialized")
}
// 打印“The anonymous creature could not be initialized”
```

### 枚举类型的可失败构造器

你可以通过一个带一个或多个形参的可失败构造器来获取枚举类型中特定的枚举成员。如果提供的形参无法匹配任何枚举成员，则构造失败。

```swift
enum TemperatureUnit {
    case Kelvin, Celsius, Fahrenheit
    init?(symbol: Character) {
        switch symbol {
        case "K":
            self = .Kelvin
        case "C":
            self = .Celsius
        case "F":
            self = .Fahrenheit
        default:
            return nil
        }
    }
}
```

带原始值的枚举类型会自带一个可失败构造器 `init?(rawValue:)`，该可失败构造器有一个合适的原始值类型的 `rawValue` 形参，选择找到的相匹配的枚举成员，找不到则构造失败。


```swift
enum TemperatureUnit: Character {
    case Kelvin = "K", Celsius = "C", Fahrenheit = "F"
}

let fahrenheitUnit = TemperatureUnit(rawValue: "F")
if fahrenheitUnit != nil {
    print("This is a defined temperature unit, so initialization succeeded.")
}
// 打印“This is a defined temperature unit, so initialization succeeded.”

let unknownUnit = TemperatureUnit(rawValue: "X")
if unknownUnit == nil {
    print("This is not a defined temperature unit, so initialization failed.")
}
// 打印“This is not a defined temperature unit, so initialization failed.”
```

### 必要构造器

在类的构造器前添加 required 修饰符表明所有该类的子类都必须实现该构造器：

```swift
class SomeClass {
    required init() {
        // 构造器的实现代码
    }
}
```







