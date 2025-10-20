# GLBizStorage：Serverless 存储组件

## 简介

`GLBizStorage` 是一个类似于 RealmSwift 的无服务器数据库解决方案，专为 iOS 15 及以上版本设计。它提供了一套便捷的 API 来操作数据库，支持将数据直接存储到服务端，并在客户端进行缓存（未来版本将支持 GRDB 本地缓存）。

## 功能

1. **数据库配置与初始化**：
   - `GLBizStorage` 提供了一个 `Configuration` 结构体，用于配置数据库的名称、存储目录、远程主机等信息。
   - 初始化时，如果未禁用本地存储，则会设置数据库。

2. **数据操作**：
   - 提供了异步的 `asyncWrite` 和 `asyncDelete` 方法，用于将数据写入或删除。
   - `asyncWrite` 方法会根据数据是否已有存储 ID 来决定是更新还是保存新数据。
   - `asyncDelete` 方法用于删除指定的数据库记录。

3. **数据查询**：
   - 提供了 `asyncRead` 和 `asyncGet` 方法，用于异步读取数据。
   - `asyncRead` 方法用于根据查询条件获取数据集合。
   - `asyncGet` 方法用于根据存储 ID 获取单个数据项。

4. **分页加载**：
   - `PaginationCollection` 类用于支持数据的分页加载。
   - 支持分页加载数据，并监听数据的增删改变化。
   - 懒加载功能将在未来版本中提供。

5. **数据库 Schema**：
   - `GLBizStorageSchema` 类定义了数据库的基本结构和操作方法。
   - 提供了 `toSaveRequest` 和 `toUpdateRequest` 方法，用于将数据转换为保存或更新请求。
   - 使用 `GLBizPersisted` 属性包装器来简化属性的持久化。

   ### 示例：使用 `GLBizPersisted` 属性包装器

   在 `KnitHistorySchema.swift` 文件中，我们可以看到 `GLBizPersisted` 属性包装器的使用示例：
   ```swift
   class KnitHistoryItem: GLBizStorageSchema, Equatable, Identifiable {
       @GLBizPersisted(keyPath: "title") var title: String?
       @GLBizPersisted(keyPath: "lastMessage") var lastMessage: String?
       @GLBizPersisted(keyPath: "historyType") var historyType: Int?
       // 其他属性省略...
   }   ```

   通过使用 `@GLBizPersisted` 属性包装器，我们可以轻松地将类的属性与数据库中的字段进行映射和持久化。

6. **并发支持**：
   - 使用 `GLBizStorageActor` 全局 Actor 来确保数据库操作的隔离性和线程安全。

7. **错误处理**：
   - 定义了 `GLBizStorageError` 枚举，用于处理各种可能的错误情况，如索引超出范围、数据加载失败、序列化错误等。

## 未来计划

- 支持 GRDB 本地缓存功能。
- 提供懒加载功能以提高数据加载效率。

## 作者

wang.zhilong, wang.zhilong@glority.cn

