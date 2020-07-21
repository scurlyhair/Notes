# CoreData

## 概述

CoreData 是基于 ORM（Object-Relation-Mapping）的数据持久化框架。

> ORM（Object-Relation-Mapping）：对象关系映射，就是把对象的属性和表中的字段自动映射

CoreData 的核心元素如下：

- **store** 数据实际储存的文件
- **objectModel** 数据实体的属性以及相互间的关系
- **context** 数据操作的执行环境
- **object** 数据对象
- **coordinator** 管理 store

它们对应的抽象类如下：

```
1. store - NSPersistentStore
代表储存文件的抽象类，文件是SQLite、XML、Binary等类型。

2. objectModel - NSManagedObjectModel
代表实体及实体关系的描述文件的抽象类
- example.xcdatamodeld 文件，而此文件最终会被编译为 example.momd
- example.xcdatamodel 文件，而此文件最终会被编译为 example.mom

3. context - NSManagedObjectContext 
操作数据对象的上下文环境

4. object - NSManagedObject
数据对象

5. coordinator - NSPersistentStoreCoordinator
- 关联 store 和 objectModel
- 整合多个 store 并向 context 提供通用的接口
```

下图可以帮助我们更好地理解个元素之间的关系：

![CoreData_01](CoreData_01.jpg)

这就是 Core Data 的整个架构。其他所有东西都在围绕着这个核心进行扩展。

## CoreDataStack

CoreDataStack 是我们自己创建的类，它将 context，store，coordinator，objectModel 组合在一起，为数据库的相关操作提供支持。

stack 实例的核心是 coordinator。每个 stack 都包含一个 coordinator。这个 coordinator 可能会连接多个 context 或多个 store。

下面来看下这些组件是如何进行组合工作的。实际上，这也是 stack 的初始化过程。

1. 创建 objectModel
2. 使用 object Model 创建 coordinator
3. 创建 store 并连接到 coordinator
4. 创建 context 并连接到 coordinator

```swift
import Foundation
import CoreData

class CoreDataStack {
    init() {
        // 1. 创建 objectModel
        guard let URL = Bundle.main.url(forResource: "Example", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: URL) else {
            print("Can't find momd file!")
            return
        }
        
        // 2. 创建 coordinator
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // 3. 创建 store 并连接到 coordinator
        guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            print("Can't find document directory!")
            return
        }
        let storeURL = documentURL.appendingPathComponent("Example.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            fatalError("Error adding store to coordinator. \(error)")
        }
        
        // 4. 创建 context 并连接到 coordinator
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
    }
}
```

至此，我们便可以借助 context 来进行数据的操作，比如:

```swift
// 拉取数据
do {
    _ = try context.fetch(NSFetchRequest<User>())
} catch {}

// 保存上下文
if context.hasChanges {
    do {
        try context.save()
    } catch {
        print("Error saving context. \(error)")
    }
}
```

实际上，我们并不会将这个过程全部堆在 `DataCoreStack` 的初始化方法中，这样来写只是为了更方便地去理解其内部元素的创建过程以及组合关系。

一般而言，我们会将 context 暴露给外部以供使用。通过添加扩展让 stack 支持更多的操作。


**另外**：

在 iOS10 以上的版本苹果引入 `NSPersistentContainer` 类来简化 stack 的创建：

```swift
let container = NSPersistentContainer(name: "Example")
container.loadPersistentStores(completionHandler: { _, error in
    if let error = error {
        fatalError("Unresolved error \(error)")
    }
})
```

只需要将 name 参数设置为 .xcdatamodeld 的文件名即可。container 将会自动完成我们上面的初始化过程，并为我们提供一系列需要的属性和方法。

```swift
let objectModel = container.managedObjectModel

let context = container.viewContext

let coordinator = container.persistentStoreCoordinator

let backgroundContext = container.newBackgroundContext()

container.performBackgroundTask { (NSManagedObjectContext) in
    
}
```

对于多个 store，苹果引入了一个 `NSPersistentStoreDescription` 类来描述 store 的特性。

我们可以通过给 container 添加多个 store description 然后调用 `loadPersistentStores` 函数来实现。

## 常见问题

### 创建 NSManagedObject

假设我们需要像数据库中储存一个 User（已在.xcmomd文件中定义），按照日常习惯我们会这样写：

```swift
let user = User()
context.insert(user)
if context.hasChanges {
    do {
        try context.save()
    } catch {
        // ...
    }
}
```

在编译时会报错：

```
error: Failed to call designated initializer on NSManagedObject class 'EntityName'
```

因为 `NSManagedObject ` 实例的创建需要两个元素：

- `NSEntityDescritption` - 描述实体名，实体属性，实体的关系
- `NSManagedObjectContext` - 执行上下文，会追踪 `NSManagedObject` 实例的改变以及其关系的变化

`NSEntityDescription` 提供了一个类方法来创建 `NSManagedObject ` 实例并添加到 context：

```swift
let user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as! User
```

参考： [https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/CreatingObjects.html](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/CreatingObjects.html)

### 拉取数据

拉取数据的时候一定要显式地声明 EntityName

```swift
let request = NSFetchRequest<User>(entityName: "User")
do {
    let users = try context.fetch(request)
} catch {
    // ...
}
```

如果在 request 中不声明 EntityName:

```swift
let request = NSFetchRequest<User>()
```

编译器会报错:

```
executeFetchRequest:error: A fetch request must have an entity.
```

### NSManagedObjectContext 创建

在 `NSManagedObjectContext` 的初始化方法中，使用 NSManagedObjectContextConcurrencyType 来指定其并发模式。

使用 `. mainQueueConcurrencyType` 模式的 context 无论在哪个线程，它的 `perform` 或者 `performAndWait` 闭包中的方法都会被添加到主线程执行。

而使用 `.privateQueueConcurrencyType` 模式的 context 并不会自动指定线程或队列，需要我们手动操作。

假设要在后台队列中添加 1000 个 User， 需要先创建一个后台队列，然后在队列中创建 contex 并声明其类型为 private，这样，context 的 perform 方法执行的所有任务才会在后台执行：

```swift
let coreDataStack = CoreDataStack()
let queue = coreDataStack.backgroundQueue
queue.async {
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.perform {
        for i in 0..<1000 {
            let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User

            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // ...
                    context.delete(user)
                }
            }
        }
    }
}
```

### 自动创建 NSManagedObject Subclass

在使用 Editor - Create NSManagedObject Subclass 自动生成实体对象的代码文件时，需要将对应 Entity 检查器中的 Codegen 选项设置为 Manual/None，否则 会报错：

```
error: Multiple commands produce '/Users/scurlyhair/Library/Developer/Xcode/DerivedData/Example-giiffmhdaxedwmfftsajasmmovio/Build/Intermediates.noindex/Example.build/Debug-iphonesimulator/Example.build/Objects-normal/x86_64/EntityName+CoreDataProperties.o':
1) Target 'Example' (project 'Example') has compile command for Swift source files
2) Target 'Example' (project 'Example') has compile command for Swift source files
```

## 多个 store

### 为什么用到多个 store

- 比如有一些敏感信息不希望被缓存在硬盘文件中时，可以选择使用 `NSInMemoryStoreType` 
- 不同的实体对于储存需求不同，比如有的需要储存为只读文件，有的需要储存为 SQLite，而另一些需要储存为二进制文件等。

### 如何使用多个 store

显然，我们可以通过 NSPersistentStoreDescription 创建多个 store 交给 coordinator 来管理。 

但是如何才能让实体储存在不同的 store 中呢？

如下图，我们可以在 example.xcdatamodeld 编辑器的左侧看到 ENTITIES, FETCH REQUESTS, CONFIGURATIONS  三个选项。其中的 CONFIGURATIOS 标签栏就是用来做这件事情的。

![CoreData_02](CoreData_02.png)

Editor -> Add Configuration 添加一个新的 Configuration。将 Entities 拖拽到新的 Configuration 中。

在 store 的初始化方法（或者 StoreDescription 的属性）中，我们可以为其提供一个 configurationName：

```swift
let store = NSPersistentStore(persistentStoreCoordinator: NSPersistentStoreCoordinator?, configurationName: String?, at: URL, options: [AnyHashable : Any]?)

let storeDescription = NSPersistentStoreDescription()
storeDescription.configurationName = "SomeConfiguration"
```

在 coordinator 加载这个 store 时，会为其匹配对应的 Configuration，数据操作也会作用于相应的的 store。

### 不同 store 中的实体关系

CoreData 并**不支持**不同 store 中的实体间的关系。

如果必须要这样做，那么需要使用 `fetched properties` 来实现。

## 数据迁移

### 数据迁移的时机

当我们需要对 objectModel 做修改的时候，就需要新建一个 objectModel 版本。

coordinator 在加载 store 时会对当前的 objectModel 和 已有的 store 对应的 objectModel 版本进行比较， 如果不一致就会触发数据迁移。

NSPersistentStoreDescription 的 `shouldMigrateStoreAutomatically ` 属性决定是否自动执行数据迁移。

### 数据迁移的过程

1. 将 old store 中的所有 object 复制到 new store 中
2. 根据关系映射给 new store 中的 object 添加关系
3. 进行数据验证

迁移成功之后会删除 old store。如果迁移过程中出现了错误则不会对 old store 造成任何影响。

### 数据迁移类型

CoreData 中数据迁移可以分为两类：

- Lightweight Migration 自动推断模型映射
- Heavyweight Migration 手动编写模型映射

NSPersistentStoreDescription 的 `shouldInferMappingModelAutomatically` 属性决定是否使用自动推断模型映射。

CoreData 的自动推断支持大多数情况的 objectModel 的修改。我们可以通过 `NSMappingModel` 的 `inferredMappingModel(forSourceModel:destinationModel:)` 方法来查看产生的映射模型，如果生成失败则会返回 `nil`。

对于较为复杂的模型映射，我们需要手动编写映射代码。

参考链接：

- [https://developer.apple.com/library/archive/documentation/DataManagement/Devpedia-CoreData/coreDataOverview.html](https://developer.apple.com/library/archive/documentation/DataManagement/Devpedia-CoreData/coreDataOverview.html)

