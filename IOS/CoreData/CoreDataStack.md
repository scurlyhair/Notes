# CoreDataStack

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