# GCD

Grand CentralDispatch

## 1 定义
### 1.1 DispatchQueue
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

### 1.2 DispatchWorkItem
任务对象
#### 属性
- **qos: DispatchQos** 优先级
- **flags: DispatchWorkItemFlags**  执行标识
	- `barrier`。 这个是比较常用的参数。如果`DispatchWorkItem`被提交到`.concurrent`并发队列，那么这个`DispatchWorkItem`中的操作会具有独占性(防止此`DispatchWorkItem`中的`block`内的操作与其他操作同时执行)。
如果直接执行这个`DispatchWorkItem`，没有任何效果
	- `detached`。 表明`DispatchWorkItem`会无视当前执行上下文的参数(`QoS class`, `os_activity_t` 和进程间通信请求参数)。
如果直接执行`DispatchWorkItem`，在复制这些属性给这个`block`前，`block`在执行期间会移除在调用线程中的这些属性。
如果`DispatchWorkItem`被添加到队列中，`block`在执行时会采用队列的属性，或者赋值给`block`的属性
	- `assignCurrentContext`。 表明`DispatchWorkItem`在被创建时，应该被指定执行上下文参数。这些参数包括：`QoS class`, `os_activity_t` 和进程间通信请求参数。
如果`DispatchWorkItem`被直接调用，`DispatchWorkItem`在调用的线程中将采用这些参数。
如果`DispatchWorkItem`被提交到队列中，这些参数会被提交时的执行上下文中的参数替代。
如果`QoS`类为`DISPATCH_BLOCK_NO_QOS_CLASS`或`dispatch_block_create_with_qos_class`生成的值，那么这个值会取代当前的值。
	- `noQoS`。 不指定`QoS`，由调用线程或队列来指定
	- `inheritQoS`。 表明`DispatchWorkItem`会采用队列的`QoS class`，而不是当前的
	- `enforceQoS`。 表明`DispatchWorkItem`会采用当前的`QoS class`，而不是队列的
- **block: @escaping @convention(block) () -> Void** 任务

#### 方法
- `perform()` 执行
- `wait()` 等待执行完成
- `notify(queue: DispatchQueue, execute: DispatchWorkItem)` 执行完成之后发出通知

### 1.3 DispatchGroup
调度编组

### 1.4 Semaphore
信号量。可用来控制访问资源的数量的标识
#### 初始化
- `DispatchSemaphore(value: Int)` value 的值就是并发线程数

### 方法
- `wait()`
- `siginal()`


## 2 常用场景
### 2.1 耗时任务
```swift
// 耗时任务
let item1 = DispatchWorkItem {
    print("work item 1")
}
// 更新UI
let item2 = DispatchWorkItem {
    print("work item 2")
}

// 方案一：
DispatchQueue.global().async(execute: item1)
item1.notify(queue: DispatchQueue.main, execute: item2)

// 方案二：
DispatchQueue.global().async(execute: item1)
item1.wait()
DispatchQueue.main.async(execute: item2)
```

### 2.2 多任务调度
在`queue1`执行`item1`，在`queue2`执行`item2`，两个任务都执行完成之后在主队列执行`item3`。

```swift
// 耗时任务
let item1 = DispatchWorkItem {
    print("work item 1")
}
// 更新UI
let item2 = DispatchWorkItem {
    print("work item 2")
}
// 更新UI
let item3 = DispatchWorkItem {
    print("work item 3")
}

// 耗时队列
let queue1 = DispatchQueue(label: "com.expensive.queue", qos: .background, attributes: [], autoreleaseFrequency: .workItem, target: DispatchQueue.global())
// 更新UI队列
let queue2 = DispatchQueue(label: "com.UI.queue", qos: .userInteractive, attributes: [], autoreleaseFrequency: .workItem, target: DispatchQueue.main)

// 调度编组
let group = DispatchGroup()
group.enter()
queue1.async(group: group, execute: item1)
group.leave()
group.enter()
queue2.async(group: group, execute: item2)
group.leave()
group.notify(queue: DispatchQueue.main, work: item3)
```

### 2.3 线程锁
有两种方法，分别是`DispatchSemaphore` 和任务对象`DispatchWorkItemFlag`的`Barrier`模式。
#### DispatchSemaphore
设定两个线程可用，不同队列

```swift
let queue1 = DispatchQueue(label: "com.test1.queue")
let queue2 = DispatchQueue(label: "com.test2.queue")
let queue3 = DispatchQueue(label: "com.test3.queue")
let semaphore = DispatchSemaphore(value: 2)
queue1.async {
    semaphore.wait()
    print("queue1 will sleep")
    sleep(2)
    print("queue1 did wake up")
    semaphore.signal()
}
queue2.async {
    semaphore.wait()
    print("queue2 will sleep")
    sleep(2)
    print("queue2 did wake up")
    semaphore.signal()
}
queue3.async {
    semaphore.wait()
    print("queue3 will sleep")
    sleep(2)
    print("queue3 did wake up")
    semaphore.signal()
}

/** log:
 queue1 will sleep
 queue2 will sleep
 queue1 did wake up
 queue3 will sleep
 queue2 did wake up
 queue3 did wake up
 */
```
#### DispatchWorkItem
文件读写，同一个队列

```swift
let item1 = DispatchWorkItem {
    print("read 1")
}
let item2 = DispatchWorkItem {
    print("read 2")
}
let item3 = DispatchWorkItem(qos: .default, flags: .barrier, block: {
    print("will execute write 1")
    sleep(2)
    print("write 1 done")
})
let item4 = DispatchWorkItem(qos: .default, flags: .barrier, block: {
    print("will execute write 2")
    sleep(2)
    print("write 2 done")
})
let item5 = DispatchWorkItem {
    print("read 3")
}
let queue = DispatchQueue(label: "com.test.queue", qos: .background, attributes: [.concurrent], autoreleaseFrequency: .workItem, target: DispatchQueue.global())

queue.async {
    item1.perform()
    item2.perform()
    item3.perform()
    item4.perform()
    item5.perform()
}

/** log:
 read 1
 read 2
 will execute write 1
 write 1 done
 will execute write 2
 write 2 done
 read 3
 */
```

## 3 NSCondition

### NSCondition + GCD

需求场景： 

并发执行下载任务一、下载任务二，两个文件都下载完成之后执行任务三。

```swift
func download() {
    let queue = DispatchQueue.global()
    
    // 下载任务一
    let workItem1 = DispatchWorkItem {
        let condition = NSCondition()
        
        DownLoader().download(urlString: urlA, onSuccess: { tmpURL, response, error in
            print("download 1 complete")
            print(Thread.current)
            condition.signal()
        })
        
        condition.lock()
        condition.wait()
        condition.unlock()
    }
    // 下载任务二
    let workItem2 = DispatchWorkItem {
        let condition = NSCondition()
        
        DownLoader().download(urlString: urlB, onSuccess: { tmpURL, response, error in
            print("download 2 complete")
            print(Thread.current)
            condition.signal()
        })
        
        condition.lock()
        condition.wait()
        condition.unlock()
    }
    // 任务三
    let workItem3 = DispatchWorkItem {
        print("all download complete")
    }
    
    
    let group = DispatchGroup()
    group.enter()
    queue.async(group: group, execute: workItem1)
    group.leave()
    group.enter()
    queue.async(group: group, execute: workItem2)
    group.leave()
    group.notify(queue: queue, work: workItem3)
}

```

### NSCondition + Thread

用于协调线程间的通信

需求：

1. 模拟下载五张图片、五篇文章；
2. 图片下载了两张之后，暂停下载，转而开启文章下载；
3. 下载三篇文章之后，暂停下载，转而继续下载剩下的三张图片。
4. 图片下载完成后，下载完成剩下的两篇文章。

> 假设下载均为同步操作

```swift
class ViewController: UIViewController {
    var downImages: Thread?
    var downArticles: Thread?
    
    let imageCondition = NSCondition()
    let articleCondition = NSCondition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downImages = Thread(target: self, selector: #selector(downloadImages), object: nil)
        downArticles = Thread(target: self, selector: #selector(downloadArticles), object: nil)
        downImages?.start()
        
    }
    
    @objc private func threadPrint() {
        Thread.sleep(forTimeInterval: 2)
        print("After 2 seconds, I have been performed. I am \(Thread.current)")
    }
    
    @objc fileprivate func downloadImages() {
        for index in 1...5 {
            print("Downloading No.\(index) image.")
            Thread.sleep(forTimeInterval: 1)
            
            if index == 2 {
                //start downArticles.开启下载文章的线程
                downArticles?.start()
                
                //Lock the image thread.加锁，让下载图片的线程进入等待状态
                imageCondition.lock()
                imageCondition.wait()
                imageCondition.unlock()
            }
        }
        print("All images have been completed.")
        
        //Signaling the article when all images completed.
//        等图片都下载完成之后，激活下载文章的进程
        articleCondition.signal()
    }
    
    @objc fileprivate func downloadArticles() {
        for index in 1...5 {
            print("The No.\(index) article will be downloading.")
            Thread.sleep(forTimeInterval: 1)
            if index == 3 {
                //Signaling the image thread, let it continue to down.
                //激活图片的线程，让它继续下载图片
                imageCondition.signal()
                
                //Lock the article thread.加锁，让下载文章的线程进入等待状态
                articleCondition.lock()
                articleCondition.wait()
                articleCondition.unlock()
                
            }
        }
        print("There are 5 articles.")
        
    }
}
```






