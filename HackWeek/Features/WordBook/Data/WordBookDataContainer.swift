//
//  WordBookDataContainer.swift
//  HackWeek
//
//  Created by Stephen on 2025/10/14.
//

import Foundation
import SwiftData

/// SwiftData 数据容器配置和管理
@MainActor
final class WordBookDataContainer {
    /// 单例实例
    static let shared = WordBookDataContainer()

    /// SwiftData ModelContainer
    lazy var modelContainer: ModelContainer = {
        do {
            let container = try ModelContainer(
                for: WordBook.self, WordModel.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
            print("✅ SwiftData container initialized successfully")
            return container
        } catch {
            fatalError("❌ Failed to initialize SwiftData container: \(error)")
        }
    }()

    /// 主上下文（用于 UI 操作）
    var mainContext: ModelContext {
        return modelContainer.mainContext
    }

    /// 后台上下文（用于后台操作）
    var backgroundContext: ModelContext {
        let context = ModelContext(modelContainer)
        context.autosaveEnabled = false
        return context
    }

    private init() {}

    // MARK: - Save Operations
    /// 保存主上下文
    func saveMainContext() {
        do {
            try mainContext.save()
            print("✅ Main context saved successfully")
        } catch {
            print("❌ Failed to save main context: \(error)")
        }
    }

    /// 保存指定上下文
    func saveContext(_ context: ModelContext) {
        do {
            try context.save()
            print("✅ Context saved successfully")
        } catch {
            print("❌ Failed to save context: \(error)")
        }
    }

    // MARK: - Background Operations
    /// 在后台上下文中执行操作
    func performBackgroundTask<T>(_ operation: @escaping (ModelContext) throws -> T) async rethrows -> T {
        let context = backgroundContext
        let result = try operation(context)
        do {
            try context.save()
        } catch {
            print("❌ Failed to save background context: \(error)")
        }
        return result
    }

    // MARK: - Data Management
    /// 清空所有数据（仅用于开发/测试）
    func clearAllData() {
        do {
            try mainContext.delete(model: WordBook.self)
            try mainContext.delete(model: WordModel.self)
            try mainContext.save()
            print("✅ All data cleared successfully")
        } catch {
            print("❌ Failed to clear all data: \(error)")
        }
    }

    /// 获取数据统计信息
    func getDataStatistics() -> (wordBookCount: Int, wordCount: Int) {
        let wordBookDescriptor = FetchDescriptor<WordBook>()
        let wordDescriptor = FetchDescriptor<WordModel>()

        let wordBookCount = (try? mainContext.fetchCount(wordBookDescriptor)) ?? 0
        let wordCount = (try? mainContext.fetchCount(wordDescriptor)) ?? 0

        return (wordBookCount: wordBookCount, wordCount: wordCount)
    }
}

// MARK: - Convenience Extensions
extension WordBookDataContainer {
    /// 获取今天的单词本（如果没有则创建）
    func getOrCreateTodayWordBook() -> WordBook {
        let today = Date()
        let predicate = WordBook.predicate(forDate: today)
        let descriptor = FetchDescriptor<WordBook>(predicate: predicate)

        if let existingWordBook = try? mainContext.fetch(descriptor).first {
            return existingWordBook
        } else {
            let newWordBook = WordBook(recordDate: today)
            mainContext.insert(newWordBook)
            saveMainContext()
            print("✅ Created new WordBook for today: \(newWordBook.formattedDateString)")
            return newWordBook
        }
    }

    /// 获取指定日期的单词本（如果没有则创建）
    func getOrCreateWordBook(for date: Date) -> WordBook {
        let predicate = WordBook.predicate(forDate: date)
        let descriptor = FetchDescriptor<WordBook>(predicate: predicate)

        if let existingWordBook = try? mainContext.fetch(descriptor).first {
            return existingWordBook
        } else {
            let newWordBook = WordBook(recordDate: date)
            mainContext.insert(newWordBook)
            saveMainContext()
            print("✅ Created new WordBook for date: \(newWordBook.formattedDateString)")
            return newWordBook
        }
    }
}
