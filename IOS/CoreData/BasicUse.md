# 使用示例

基本使用方法网络上很多，本文主要介绍在基本使用过程中一些要点和典型的坑。

基于 CoreDataStack 实现，其核心代码附在文末。

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

TODO： 原理

附：

**CoreDataStack:**

```swift
import Foundation
import CoreData

class CoreDataStack {
    /// Background queue
    lazy var backgroundQueue: DispatchQueue = DispatchQueue(label: "core_data")
    
    /// Main queue context
    lazy var mainContext: NSManagedObjectContext? = {
        if let coordinator = storeCoordinator {
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = coordinator
            return context
        }
        Console.logError("Construct mainContext failed!")
        return nil
    }()
    
    /// Store Coordinator
    lazy var storeCoordinator: NSPersistentStoreCoordinator? = {
        if let model = managedObjectModel, let descriptions = storeDescriptions {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            
            for description in descriptions {
                coordinator.addPersistentStore(with: description) { (description, error) in
                    if let error = error {
                        fatalError("CoreDtaStack - Error adding store to storeCoordinator, \(error.localizedDescription)")
                    }
                }
            }
            return coordinator
        }
        Console.logError("Construct storeCoordinator failed!")
        return nil
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel? = {
        if let URL = Bundle.main.url(forResource: "Example", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: URL) {
            return model
        }
        Console.logError("Construct managedObjectModel failed!")
        return nil
    }()
    
    private lazy var storeDescriptions: [NSPersistentStoreDescription]? = {
        var descriptions: [NSPersistentStoreDescription] = []
        if let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            let description = NSPersistentStoreDescription()
            description.url = documentURL.appendingPathComponent("Example.sqlite")
            description.type = NSSQLiteStoreType
            descriptions.append(description)
        }
        if descriptions.count > 0 {
            return descriptions
        }
        Console.logError("Construct storeDescriptions failed!")
        return nil
    }()
}
```