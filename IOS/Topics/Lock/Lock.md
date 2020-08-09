# 锁&原子操作

## 1 基本概念

### 1.1 线程安全

线程安全就是多线程访问时，采用了加锁机制，当一个线程访问该类的某个数据时，进行保护，其他线程不能进行访问直到该线程读取完，其他线程才可使用。不会出现数据不一致或者数据污染。 线程不安全就是不提供数据访问保护，有可能出现多个线程先后更改数据造成所得到的数据是脏数据。

### 1.2 原子操作

如果一个属性是原子属性，那么它就是线程安全的。通过加锁机制来保证属性的原子性。

### 1.3 锁的类型

- **Semaphore 信号量**。允许 n 个线程对指定的资源（或代码）进行访问。
- **Mutex 互斥锁**。保证每次只有一条线程对指定的资源（或代码）进行访问。它可以看做是信号量最大值为 1 的 Semaphore。
- **Spinlock 自旋锁**。如果当前资源处于锁定状态，自旋锁会让要进行访问的线程一直进行循环等待，直到解锁。当需要等待的时间非常短的时候，这种锁是高效的。
- **Read-write lock 读写锁**。读操作并发，写操作的独占。在读操作频繁写操作很少情况下，这种锁是高效的。
- **Recursive lock 递归锁**。是一种互斥锁，它允许一条线程对资源进行多次上锁和解锁。虽然递归锁可以多次上锁，但是只有当上的所有锁全被解锁后，其他线程才能再次访问到此递归锁。

## 2 Swift 中锁的实现

### 2.1 实现思路
**Semaphore 信号量**

DispatchSemaphore 提供了信号量的实现。

**Mutex 互斥锁 & Recursive lock 递归锁**

`NSLock` 和 `NSRecursiveLock` 都是 OC 中的锁，在 Swift 中并没有对应的实现（虽然在 iOS开发中，他们也可以在 Swift 中使用）。

在 Swift 中，互斥锁和递归锁可以通过底层的 C 语言API 来实现：`pthread_mutex_t`。

**Spinlock 自旋锁**

自旋锁 `OSSpinLock` 已经在 iOS10 中被弃用，Swift 中也没有对应的实现方案。最接近的实现方案就是使用 `os_unfair_lock`

**Read-write lock 读写锁**

在 Swift 中可以使用 `pthread_rwlock_t` 来实现读写锁。

### 2.2 实现过程

除读写锁外，其他锁都可以抽象出两个行为 -- 加锁和解锁，因此我们定义一个锁的协议：

```swift
protocol Lock {
    func lock()
    func unlock()
}
```
然后为不同的锁编写此协议的实现：

```swift
// 互斥锁
final class Mutex: Lock {
    private var mutex: pthread_mutex_t = {
        var mutex = pthread_mutex_t()
        pthread_mutex_init(&mutex, nil)
        return mutex
    }()

    func lock() {
        pthread_mutex_lock(&mutex)
    }

    func unlock() {
        pthread_mutex_unlock(&mutex)
    }
}
```

```swift
// 自旋锁
final class SpinLock: Lock {
    private var unfairLock = os_unfair_lock_s()

    func lock() {
        os_unfair_lock_lock(&unfairLock)
    }

    func unlock() {
        os_unfair_lock_unlock(&unfairLock)
    }
}
```

```swift
// 读写锁
final class ReadWriteLock {
    private var rwlock: pthread_rwlock_t = {
        var rwlock = pthread_rwlock_t()
        pthread_rwlock_init(&rwlock, nil)
        return rwlock
    }()
    
    func writeLock() {
        pthread_rwlock_wrlock(&rwlock)
    }
    
    func readLock() {
        pthread_rwlock_rdlock(&rwlock)
    }
    
    func unlock() {
        pthread_rwlock_unlock(&rwlock)
    }
}
```

### 2.3 让一个属性具有原子性

```swift
// 互斥锁 | 自旋锁
struct AtomicProperty {
    private var underlyingFoo = 0
    private let lock: Lock

    init(lock: Lock) {
        self.lock = lock
    }

    var foo: Int {
        get {
            lock.lock()
            let value = underlyingFoo
            lock.unlock()
            return value
        }
        set {
            lock.lock()
            underlyingFoo = newValue
            lock.unlock()
        }
    }
}

// Usage
let sample = AtomicProperty(lock: SpinLock())
_ = sample.foo
```

```swift
// 读写锁
class ReadWriteLockAtomicProperty {
    private var underlyingFoo = 0
    private let lock = ReadWriteLock()
    
    var foo: Int {
        get {
            lock.readLock()
            let value = underlyingFoo
            lock.unlock()
            return value
        }
        set {
            lock.writeLock()
            underlyingFoo = newValue
            lock.unlock()
        }
    }
}
```

在上面的代码中：

- 我们没有直接使用API实现一个锁。而是通过抽象出自旋锁和互斥锁的共同行为，让他们遵循同样的协议，让代码具有更小的耦合性和更高的灵活度。
- `AtomicProperty` 是一个具有原子属性 `foo` 的类。其背后是通过对私有属性 `underlyingFoo` 的加锁和解锁实现。
- 我们为读写锁提供了单独的实现，因为在getter 和 setter 方法中需要实现不同的锁。

> 尽管 pthread 锁是值类型，但在 POSIX （可移植操作系统接口）中并没有定义 copy 行为，所以不能显式或隐式地对其进行复制。因此上面的锁是使用 class 来实现，而非 struct。

### 2.4 属性转换器

在上一节的例子中，我们可以看到为一个属性添加原子性，我们进行了相同范式的操作。为了避免每次生命原子属性都要编写如此复杂的代码。我们可以利用 Swift 提供的属性转换器 `propertyWrapper` 功能，设计一个通用的解决方案。

```swift
@propertyWrapper
struct Atomic<Value> {
    private let queue = DispatchQueue(label: "com.vadimbulavin.atomic")
    private var value: Value

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    var wrappedValue: Value {
        get {
            return queue.sync { value }
        }
        set {
            queue.sync { value = newValue }
        }
    }
}
```
然后，我们可以很方便地为一个属性添加原子性：

```swift
struct MyStruct {
    @Atomic var x = 0
}

var value = MyStruct()
value.x = 1
print(value.x) // 1
```
这样，我们分别单独对这个属性的 set 和 get 操作添加了原子性。但并没有对他们两者的行为进行约束，即没有实现其读和写的原子性。

```swift
var value = MyStruct()
value.x += 1 // ❌ Not atomic
```

解决方案是为 `Atomic<Value>` 属性转换器添加一个新的方法，在里面进行读写操作：

```swift
@propertyWrapper
struct Atomic<Value> {
    private let queue = DispatchQueue(label: "com.vadimbulavin.atomic")
    private var value: Value

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    var wrappedValue: Value {
        get {
            return queue.sync { value }
        }
        set {
            queue.sync { value = newValue }
        }
    }
    // 新添加的方法，在此方法中对数据进行赋值
    mutating func mutate(_ mutation: (inout Value) -> Void) {
        return queue.sync {
            mutation(&value)
        }
    }
}
```

由于 `mutate` 方法在 `MyStruct` 外面不能被访问，所以需要再写一个 `increment()`方法：

```swift
struct MyStruct {
    @Atomic var x = 0

    mutating func increment() {
        _x.mutate { $0 += 1 }
    }
}

var value = MyStruct()
value.increment() // `x` equals to 1
```
这样，我们就可以通过 `increment()` 函数对属性 `MyStruct.x` 进行原子操作。

但是，当我们需要添加其他原子操作的时候，又需要添加新的函数去来实现。为了避免这种情况的发生，我们可以利用 Swift 的 projected properties 把属性转换器的 `mutate` 方法暴露出来。

> 属性转换器可以通过提供一个 projectedValue 属性，将自己的接口暴露。

为此，我们需要对 `Atomic<Value>` 做一些调整：

```swift
@propertyWrapper
class Atomic<Value> { // Changing `struct` into a `class`
    var projectedValue: Atomic<Value> {
        return self
    }
    private let queue = DispatchQueue(label: "com.vadimbulavin.atomic")
    private var value: Value

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    var wrappedValue: Value {
        get {
            return queue.sync { value }
        }
        set {
            queue.sync { value = newValue }
        }
    }
    
    // The `mutating` modifier is removed
    func mutate(_ mutation: (inout Value) -> Void) {
        return queue.sync {
            mutation(&value)
        }
    }
}
```

现在，我们在 `MyStruct` 外部访问到 属性转换器的 `mutate()` 方法：

```swift
struct MyStruct {
    @Atomic var x = 0
}

var value = MyStruct()
value.$x.mutate { $0 += 1 } // `x` equals to 1
```

> `$` 操作符是一个访问属性转换器的 projected value 的语法糖。

当我们更新集合（Array、Set、Dictionary）中的某个值的时候， get 和 set 方法都会被调用，这时就需要使用 `mutate ()` 方法来保证其原子性。

```swift
struct AnotherStruct {
    @Atomic var x: [Int] = [1, 2, 3]
}

var value = AnotherStruct()
value.x[1] = 123 // ❌ This is not atomic
value.$x.mutate { $0[1] = 123 } // ✅ Atomic operation
```

`Atomic<Value>` 并不仅仅局限于作为属性转换器，它可以应用到任何类型的数据：

```swift
let one = Atomic(wrappedValue: 1)
one.mutate { $0 += 1 }
```

参考链接：

- [Atomic Properties in Swift](https://www.vadimbulavin.com/atomic-properties/)
- [Swift Atomic Properties with Property Wrappers](https://www.vadimbulavin.com/swift-atomic-properties-with-property-wrappers/)