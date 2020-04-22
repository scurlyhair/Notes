# 语言

## swift
[详情](Swift.md)








`swift` 对比 `oc` 

- 语法
	- `Statement` 不需要以分号作为结尾，但是分号可以作为同一行两个或两个以上语句的分隔符。
	- 使用点语法
	- 使用`?`标识可选。`!`标识强制解析。
	- 隐式解析的可选类型，类型后面使用`!`标识
- 其他
	- 是一种静态语言，类型安全。会在编译时期进行类型检查。
	- 如果没有显示地声明类型，`Swift`将进行类型推断，原理是去检查变量的赋值。
	- 函数是一等公民可以作为其他函数的参数和返回值
	- 增加了元组 `Tuple`。把多个值组合成一个复合值。元组内的值可以是任意类型，并不要求是相同类型。
	- 可选类型，如果变量没有被赋值，会被自动设置为`nil`
	- 没有指针。如果需要与指针交互，可以使用标准库中提供的指针和缓冲区类型。
	- 可选绑定`if... let ...`
	- 提供区间运算符 `m..<n` 和 `m...n`
	- 字符串是值类型。在实际编译时，Swift 编译器会优化字符串的使用，使实际的复制只发生在绝对必要的情况下，这意味着你将字符串作为值类型的同时可以获得极高的性能
	- 闭包。 类似于 `oc` 中的` blocks` 或者其他编程语言中的匿名函数 `Lambdas`。

	




### 下标
- 实例下标
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
```
- 类型下标
`static subscript(index: Int) -> Int`


## 比较

| | Object-C | Swift | JavaScript |
| --- | --- | --- | --- |
| 类型系统 | 动态/弱类型 | 静态/强类型 | 动态 |

## 其他
### 动态类型和静态类型
- 动态类型：灵活。但是在不知道确切类型时可能会导致异常。
- 静态类型：类型安全。

## OC
### OC的动态性
1. 动态类型。在运行时进行类型检查。
2. 动态绑定。在运行时进行
3. 动态载入