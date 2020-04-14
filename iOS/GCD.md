# GCD

Grand CentralDispatch

## 定义
### DispatchQueue
任务分发队列
#### 创建
- 主队列。系统队列 `DispatchQueue.main`
- 全局队列。系统队列 `DispatchQueue.global()`
- 自定义队列。`DispatchQueue(label: String)`

#### 属性
- **label: String** 队列标识， 一般以 com.xxx.xxx进行标志
- **qos: DispatchQos** 优先级
	- `background` 最低优先级
	- `utility`
	- `default`
	- `userInitiated`
	- `userInteractive` 最高优先级 在主线程执行
	- `unspecified` 未定义
- **attributes: DispatchQueue.Attributes** 属性。 attributes是一个结构体并遵守OptionSet协议，所以传入的参数可以为`[.option1, .option2]` 默认是串行队列
	- `concurrent` 并行队列
	- `initiallyInactive` 队列不会自动执行
- **autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency** 自动释放频率
	- `inherit` 系统默认
	- `never` GCD不会管理此队列的自动释放池
	- `workItem` 根据任务对象创建和管理自动释放池
- **target: DispatchQueue** 执行此队列的队列

#### 方法
- 同步执行 `queue.sync { ... }`
- 异步执行 `queue.async { ... }`

### DispatchWorkItem
任务对象
#### 属性
- **qos: DispatchQos** 优先级
- **flags: DispatchWorkItemFlags**  执行标识
	- barrier 阻塞方式
	- detached
	- assignCurrentContext
	- noQoS
	- inheritQoS
	- enforceQoS
- **block: @escaping @convention(block) () -> Void** 任务

#### 方法
- `perform()` 执行
- `wait()` 等待执行完成
- `notify(queue: DispatchQueue, execute: DispatchWorkItem)` 执行完成之后发出通知

### DispatchGroup
调度编组

### Semaphore
信号量。可用来控制访问资源的数量的标识
#### 初始化
- `DispatchSemaphore(value: Int)` value 的值就是并发线程数

### 方法
- `wait()`
- `siginal()`

