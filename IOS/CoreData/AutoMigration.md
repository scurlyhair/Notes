# 数据迁移

**数据迁移的时机**

当我们需要对 objectModel 做修改的时候，就需要新建一个 objectModel 版本。

coordinator 在加载 store 时会对当前的 objectModel 和 已有的 store 对应的 objectModel 版本进行比较， 如果不一致就会触发数据迁移。

NSPersistentStoreDescription 的 `shouldMigrateStoreAutomatically ` 属性决定是否自动执行数据迁移。

**数据迁移的过程**

1. 将 old store 中的所有 object 复制到 new store 中
2. 根据关系映射给 new store 中的 object 添加关系
3. 进行数据验证

迁移成功之后会删除 old store。如果迁移过程中出现了错误则不会对 old store 造成任何影响。

**数据迁移类型**

CoreData 中数据迁移可以分为两类：

- Lightweight Migration 自动推断模型映射
- Heavyweight Migration 手动编写模型映射

NSPersistentStoreDescription 的 `shouldInferMappingModelAutomatically` 属性决定是否使用自动推断模型映射。

CoreData 的自动推断支持大多数情况的 objectModel 的修改。我们可以通过 `NSMappingModel` 的 `inferredMappingModel(forSourceModel:destinationModel:)` 方法来查看产生的映射模型，如果生成失败则会返回 `nil`。

对于较为复杂的模型映射，我们需要手动编写映射代码。





