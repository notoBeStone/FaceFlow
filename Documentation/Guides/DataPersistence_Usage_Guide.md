# 数据持久化使用指南

## 概述

HackWeek 模板使用 SwiftData 作为主要的数据持久化解决方案，提供了完整的 CRUD 操作、数据关系管理、查询构建和迁移支持。本指南详细介绍如何在 SwiftUI 应用中有效使用 SwiftData 进行数据管理。

## 核心特性

- ✅ **SwiftData 集成**: 基于 Core Data 的现代化数据持久化
- ✅ **类型安全**: 使用 Swift 的类型系统确保数据安全
- ✅ **关系管理**: 支持一对一、一对多、多对多关系
- ✅ **查询构建**: 声明式查询 API
- ✅ **数据迁移**: 自动化数据模型迁移
- ✅ **异步操作**: 完整的 Swift Concurrency 支持

## 快速开始

### 1. 数据模型定义

```swift
import SwiftData
import Foundation

@Model
final class WordBook {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var recordDate: Date  // 按天组织
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade) var words: [WordModel] = []

    init(id: UUID = UUID(), recordDate: Date = Date()) {
        self.id = id
        self.recordDate = recordDate
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var wordCount: Int { return words.count }
    var masteredWordCount: Int {
        return words.filter { $0.masteryLevel >= 4 }.count
    }
}

@Model
final class WordModel {
    @Attribute(.unique) var id: UUID
    var imageData: Data              // 处理后的图片数据
    var targetLanguage: String       // 目标语言
    var word: String                 // 识别出的单词
    var masteryLevel: Int            // 掌握程度 (0-5)
    var notes: String                // 用户备注
    var createdAt: Date
    var updatedAt: Date

    // 学习计划字段
    var nextReviewDate: Date         // 下次复习日期
    var reviewInterval: Int          // 复习间隔
    var reviewCount: Int             // 复习次数
    var lastReviewDate: Date?        // 上次复习日期

    init(word: String, targetLanguage: String, imageData: Data) {
        self.id = UUID()
        self.word = word
        self.targetLanguage = targetLanguage
        self.imageData = imageData
        self.masteryLevel = 0
        self.notes = ""
        self.createdAt = Date()
        self.updatedAt = Date()
        self.nextReviewDate = Date()
        self.reviewInterval = 1
        self.reviewCount = 0
    }
}
```

### 2. 数据容器配置

```swift
import SwiftData

@MainActor
class WordBookDataContainer {
    static let shared = WordBookDataContainer()

    lazy var container: ModelContainer = {
        let schema = Schema([
            WordBook.self,
            WordModel.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            fatalError("无法创建 ModelContainer: \(error)")
        }
    }()

    var context: ModelContext {
        return container.mainContext
    }

    private init() {}
}
```

### 3. 应用集成

```swift
// 在 App 或主要视图中集成
@main
struct HackWeekApp: App {
    var body: some Scene {
        WindowGroup {
            MainAppView()
        }
        .modelContainer(WordBookDataContainer.shared.container)
    }
}

// 在视图中使用
struct MainAppView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WordBook.recordDate, order: .reverse) private var wordBooks: [WordBook]

    var body: some View {
        NavigationView {
            List(wordBooks) { wordBook in
                WordBookRowView(wordBook: wordBook)
            }
        }
    }
}
```

## 详细使用指南

### 1. CRUD 操作

#### 创建数据

```swift
class WordBookManager: ObservableObject {
    @Environment(\.modelContext) private var context

    // 创建新单词本
    func createWordBook(for date: Date) -> WordBook {
        let wordBook = WordBook(recordDate: date)
        context.insert(wordBook)

        do {
            try context.save()
            return wordBook
        } catch {
            print("保存单词本失败: \(error)")
            return wordBook
        }
    }

    // 创建新单词
    func createWord(image: UIImage, targetLanguage: String, word: String, in wordBook: WordBook) -> WordModel? {
        // 压缩图片数据
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("图片压缩失败")
            return nil
        }

        let newWord = WordModel(
            word: word,
            targetLanguage: targetLanguage,
            imageData: imageData
        )

        newWord.wordBook = wordBook
        wordBook.words.append(newWord)

        do {
            try context.save()
            return newWord
        } catch {
            print("保存单词失败: \(error)")
            return nil
        }
    }
}
```

#### 读取数据

```swift
extension WordBookManager {
    // 获取所有单词本
    func getAllWordBooks() -> [WordBook] {
        let descriptor = FetchDescriptor<WordBook>(sortBy: [SortDescriptor(\.recordDate, order: .reverse)])

        do {
            return try context.fetch(descriptor)
        } catch {
            print("获取单词本失败: \(error)")
            return []
        }
    }

    // 根据日期获取单词本
    func getWordBook(for date: Date) -> WordBook? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<WordBook>(
            predicate: #Predicate<WordBook> { wordBook in
                wordBook.recordDate >= startOfDay && wordBook.recordDate < endOfDay
            }
        )

        do {
            return try context.fetch(descriptor).first
        } catch {
            print("获取指定日期单词本失败: \(error)")
            return nil
        }
    }

    // 获取需要复习的单词
    func getWordsForReview(date: Date = Date()) -> [WordModel] {
        let descriptor = FetchDescriptor<WordModel>(
            predicate: #Predicate<WordModel> { word in
                word.nextReviewDate <= date
            },
            sortBy: [SortDescriptor(\.nextReviewDate, order: .ascending)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("获取复习单词失败: \(error)")
            return []
        }
    }
}
```

#### 更新数据

```swift
extension WordBookManager {
    // 更新单词掌握程度
    func updateWordMastery(_ word: WordModel, newLevel: Int) {
        word.masteryLevel = newLevel
        word.reviewCount += 1
        word.lastReviewDate = Date()

        // 计算下次复习时间
        word.reviewInterval = calculateNextReviewInterval(count: word.reviewCount, level: newLevel)
        word.nextReviewDate = Calendar.current.date(byAdding: .day, value: word.reviewInterval, to: Date()) ?? Date()
        word.updatedAt = Date()

        do {
            try context.save()
        } catch {
            print("更新单词失败: \(error)")
        }
    }

    // 更新单词备注
    func updateWordNotes(_ word: WordModel, notes: String) {
        word.notes = notes
        word.updatedAt = Date()

        do {
            try context.save()
        } catch {
            print("更新单词备注失败: \(error)")
        }
    }

    // 计算复习间隔（遗忘曲线算法）
    private func calculateNextReviewInterval(count: Int, level: Int) -> Int {
        let intervals = [1, 2, 4, 7, 15, 30]
        let baseInterval = count < intervals.count ? intervals[count] : intervals.last!

        // 根据掌握程度调整间隔
        let levelMultiplier = max(0.5, Double(level) / 5.0)
        return Int(Double(baseInterval) * levelMultiplier)
    }
}
```

#### 删除数据

```swift
extension WordBookManager {
    // 删除单词
    func deleteWord(_ word: WordModel) {
        context.delete(word)

        do {
            try context.save()
        } catch {
            print("删除单词失败: \(error)")
        }
    }

    // 删除单词本（级联删除所有单词）
    func deleteWordBook(_ wordBook: WordBook) {
        context.delete(wordBook)

        do {
            try context.save()
        } catch {
            print("删除单词本失败: \(error)")
        }
    }

    // 批量删除操作
    func deleteOldWordBooks(olderThan days: Int) {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!

        let descriptor = FetchDescriptor<WordBook>(
            predicate: #Predicate<WordBook> { wordBook in
                wordBook.recordDate < cutoffDate
            }
        )

        do {
            let oldWordBooks = try context.fetch(descriptor)
            for wordBook in oldWordBooks {
                context.delete(wordBook)
            }
            try context.save()
        } catch {
            print("批量删除失败: \(error)")
        }
    }
}
```

### 2. 高级查询

#### 复杂条件查询

```swift
extension WordBookManager {
    // 按语言和掌握程度查询
    func getWordsByLanguageAndMastery(language: String, minMastery: Int) -> [WordModel] {
        let descriptor = FetchDescriptor<WordModel>(
            predicate: #Predicate<WordModel> { word in
                word.targetLanguage == language && word.masteryLevel >= minMastery
            },
            sortBy: [SortDescriptor(\.word, order: .ascending)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("复杂查询失败: \(error)")
            return []
        }
    }

    // 按日期范围查询
    func getWordBooksInDateRange(from startDate: Date, to endDate: Date) -> [WordBook] {
        let descriptor = FetchDescriptor<WordBook>(
            predicate: #Predicate<WordBook> { wordBook in
                wordBook.recordDate >= startDate && wordBook.recordDate <= endDate
            },
            sortBy: [SortDescriptor(\.recordDate, order: .ascending)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("日期范围查询失败: \(error)")
            return []
        }
    }

    // 模糊搜索
    func searchWords(searchText: String) -> [WordModel] {
        let descriptor = FetchDescriptor<WordModel>(
            predicate: #Predicate<WordModel> { word in
                word.word.localizedStandardContains(searchText) ||
                word.notes.localizedStandardContains(searchText)
            },
            sortBy: [SortDescriptor(\.createdAt, order: .descending)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("搜索失败: \(error)")
            return []
        }
    }
}
```

#### 分页查询

```swift
extension WordBookManager {
    // 分页获取单词
    func getWords(offset: Int, limit: Int) -> [WordModel] {
        let descriptor = FetchDescriptor<WordModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .descending)]
        )
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset

        do {
            return try context.fetch(descriptor)
        } catch {
            print("分页查询失败: \(error)")
            return []
        }
    }

    // 获取总数（用于分页计算）
    func getTotalWordsCount() -> Int {
        do {
            return try context.fetchCount(FetchDescriptor<WordModel>())
        } catch {
            print("获取总数失败: \(error)")
            return 0
        }
    }
}
```

### 3. 数据关系管理

#### 一对多关系

```swift
// WordBook 和 WordModel 已经建立了一对多关系
extension WordBookManager {
    // 获取单词本的所有单词
    func getWordsInWordBook(_ wordBook: WordBook) -> [WordModel] {
        return Array(wordBook.words).sorted { $0.createdAt > $1.createdAt }
    }

    // 获取单词本的学习统计
    func getWordBookStats(_ wordBook: WordBook) -> (total: Int, mastered: Int, inProgress: Int) {
        let total = wordBook.words.count
        let mastered = wordBook.words.filter { $0.masteryLevel >= 4 }.count
        let inProgress = total - mastered
        return (total, mastered, inProgress)
    }
}
```

#### 多对多关系（示例）

```swift
// 如果需要多对多关系（如标签系统）
@Model
final class Tag {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    @Relationship(inverse: \WordModel.tags) var words: [WordModel] = []

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
    }
}

// 在 WordModel 中添加
@Relationship(inverse: \Tag.words) var tags: [Tag] = []
```

### 4. 数据迁移

#### 版本管理

```swift
enum SchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .v1

    static var models: [any PersistentModel.Type] {
        [WordBookV1.self, WordModelV1.self]
    }
}

@Model
final class WordBookV1 {
    @Attribute(.unique) var id: UUID
    var recordDate: Date
    var createdAt: Date
}

enum SchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version = .v2

    static var models: [any PersistentModel.Type] {
        [WordBookV2.self, WordModelV2.self]
    }
}

@Model
final class WordBookV2 {
    @Attribute(.unique) var id: UUID
    var recordDate: Date
    var createdAt: Date
    var updatedAt: Date  // 新增字段
}
```

#### 自定义迁移计划

```swift
enum WordBookSchema: SchemaVersion {
    case v1
    case v2

    static var models: [any PersistentModel.Type] {
        switch self {
        case .v1:
            return [WordBookV1.self, WordModelV1.self]
        case .v2:
            return [WordBook.self, WordModel.self]
        }
    }

    static var versionIdentifier: String? {
        switch self {
        case .v1: return "v1"
        case .v2: return "v2"
        }
    }

    static var migrationPlan: SchemaMigrationPlan {
        SchemaMigrationPlan {
            from(WordBookSchema.v1).to(WordBookSchema.v2) { oldSchema, newSchema in
                // 迁移逻辑
            }
        }
    }
}
```

### 5. 性能优化

#### 批量操作

```swift
extension WordBookManager {
    // 批量插入单词
    func batchInsertWords(_ words: [(word: String, language: String, imageData: Data)], into wordBook: WordBook) {
        let batchInsert = BatchInsertRequest(models: words.map { wordData in
            let word = WordModel(word: wordData.word, targetLanguage: wordData.language, imageData: wordData.imageData)
            word.wordBook = wordBook
            return word
        })

        do {
            try context.execute(batchInsert)
            try context.save()
        } catch {
            print("批量插入失败: \(error)")
        }
    }

    // 批量更新掌握程度
    func batchUpdateMasteryLevel(for words: [WordModel], to level: Int) {
        for word in words {
            word.masteryLevel = level
            word.updatedAt = Date()
        }

        do {
            try context.save()
        } catch {
            print("批量更新失败: \(error)")
        }
    }
}
```

#### 查询优化

```swift
extension WordBookManager {
    // 使用缓存优化频繁查询
    private var _allWordBooksCache: [WordBook]?
    private var _cacheTimestamp: Date?
    private let cacheTimeout: TimeInterval = 300 // 5分钟缓存

    func getAllWordBooksCached() -> [WordBook] {
        let now = Date()

        // 检查缓存是否有效
        if let cached = _allWordBooksCache,
           let timestamp = _cacheTimestamp,
           now.timeIntervalSince(timestamp) < cacheTimeout {
            return cached
        }

        // 更新缓存
        let wordBooks = getAllWordBooks()
        _allWordBooksCache = wordBooks
        _cacheTimestamp = now

        return wordBooks
    }

    // 清除缓存
    func clearCache() {
        _allWordBooksCache = nil
        _cacheTimestamp = nil
    }
}
```

## 实际应用示例

### 1. WordBook 管理器

```swift
class WordBookManager: ObservableObject {
    @Environment(\.modelContext) private var context
    @Published var currentWordBook: WordBook?
    @Published var words: [WordModel] = []

    init() {
        loadCurrentWordBook()
    }

    private func loadCurrentWordBook() {
        let today = Date()
        currentWordBook = getWordBook(for: today) ?? createWordBook(for: today)
        words = getWordsInWordBook(currentWordBook!)
    }

    func addWord(image: UIImage, word: String, language: String) {
        guard let wordBook = currentWordBook else { return }

        if let newWord = createWord(image: image, targetLanguage: language, word: word, in: wordBook) {
            words.insert(newWord, at: 0)
        }
    }

    func deleteWord(_ word: WordModel) {
        deleteWord(word)
        words.removeAll { $0.id == word.id }
    }

    func updateWord(_ word: WordModel, masteryLevel: Int) {
        updateWordMastery(word, newLevel: masteryLevel)

        // 更新本地数组
        if let index = words.firstIndex(where: { $0.id == word.id }) {
            words[index] = word
        }
    }
}
```

### 2. SwiftUI 视图集成

```swift
struct WordBookView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var manager = WordBookManager()
    @Query(sort: \WordBook.recordDate, order: .reverse) private var wordBooks: [WordBook]

    var body: some View {
        NavigationView {
            List {
                ForEach(wordBooks) { wordBook in
                    Section(wordBook.formattedDate) {
                        ForEach(manager.words.filter { $0.wordBook?.id == wordBook.id }) { word in
                            WordRowView(word: word) {
                                manager.updateWord(word, masteryLevel: min(word.masteryLevel + 1, 5))
                            }
                        }
                    }
                }
            }
            .navigationTitle("单词本")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加") {
                        // 打开相机或添加界面
                    }
                }
            }
        }
    }
}
```

### 3. 数据同步服务

```swift
class DataSyncService {
    static let shared = DataSyncService()
    private let manager = WordBookManager()

    // 同步到云端
    func syncToCloud() async {
        let wordBooks = manager.getAllWordBooks()

        for wordBook in wordBooks {
            await syncWordBookToCloud(wordBook)
        }
    }

    private func syncWordBookToCloud(_ wordBook: WordBook) async {
        // 实现云端同步逻辑
        do {
            let data = try JSONEncoder().encode(wordBook)
            // 上传到服务器
        } catch {
            print("同步失败: \(error)")
        }
    }

    // 从云端恢复
    func restoreFromCloud() async {
        // 实现从云端恢复逻辑
    }
}
```

## 测试策略

### 单元测试

```swift
import XCTest
import SwiftData
@testable import YourApp

class WordBookManagerTests: XCTestCase {
    var manager: WordBookManager!
    var context: ModelContext!

    override func setUp() {
        super.setUp()
        let container = ModelContainer(for: WordBook.self, WordModel.self)
        context = ModelContext(container)
        manager = WordBookManager()
    }

    func testCreateWordBook() {
        let date = Date()
        let wordBook = manager.createWordBook(for: date)

        XCTAssertNotNil(wordBook)
        XCTAssertEqual(wordBook.recordDate.timeIntervalSince(date), 0, accuracy: 1)
    }

    func testAddWordToWordBook() {
        let wordBook = manager.createWordBook(for: Date())
        let testImage = UIImage(systemName: "photo")!
        let word = manager.createWord(
            image: testImage,
            targetLanguage: "English",
            word: "test",
            in: wordBook
        )

        XCTAssertNotNil(word)
        XCTAssertEqual(wordBook.words.count, 1)
    }
}
```

### UI 测试

```swift
import XCTest

class WordBookUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }

    func testAddNewWord() {
        // 点击添加按钮
        app.buttons["Add"].tap()

        // 模拟拍照流程
        app.buttons["Capture"].tap()

        // 验证单词已添加
        let newWord = app.staticTexts["test"]
        XCTAssertTrue(newWord.waitForExistence(timeout: 5))
    }
}
```

## 常见问题

### Q: 如何处理大数据量的性能问题？
A: 使用分页查询、数据缓存和后台处理：

```swift
// 分页加载
func loadWordsPage(page: Int, pageSize: Int) {
    let offset = page * pageSize
    let words = getWords(offset: offset, limit: pageSize)

    DispatchQueue.main.async {
        self.words.append(contentsOf: words)
    }
}
```

### Q: 如何实现数据备份和恢复？
A: 实现导出导入功能：

```swift
func exportData() -> URL? {
    let wordBooks = getAllWordBooks()

    do {
        let data = try JSONEncoder().encode(wordBooks)
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("backup.json")

        try data.write(to: fileURL)
        return fileURL
    } catch {
        print("导出失败: \(error)")
        return nil
    }
}
```

### Q: 如何处理并发访问？
A: SwiftData 会自动处理并发访问，但需要注意主线程操作：

```swift
@MainActor
func updateWordOnMainThread(_ word: WordModel) {
    word.masteryLevel += 1
    do {
        try context.save()
    } catch {
        print("保存失败: \(error)")
    }
}
```

### Q: 如何实现数据统计和分析？
A: 使用查询聚合功能：

```swift
func getLearningStats() -> (totalWords: Int, avgMastery: Double, streakDays: Int) {
    let words = getAllWords()
    let totalWords = words.count
    let avgMastery = words.isEmpty ? 0 : Double(words.reduce(0) { $0 + $1.masteryLevel }) / Double(totalWords)
    let streakDays = calculateCurrentStreak()

    return (totalWords, avgMastery, streakDays)
}
```

---

*SwiftData 为 HackWeek 提供了现代化的数据持久化解决方案，确保数据安全、性能优异且易于维护。*