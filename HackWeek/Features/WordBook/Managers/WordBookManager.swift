//
//  WordBookManager.swift
//  HackWeek
//
//  Created by Stephen on 2025/10/14.
//

import Foundation
import SwiftData
import UIKit

/// 单词本数据管理器 - 提供统一的数据管理接口
@MainActor
final class WordBookManager: ObservableObject {
    /// 单例实例
    static let shared = WordBookManager()

    /// 数据容器
    private let dataContainer = WordBookDataContainer.shared

    /// 主上下文
    private var context: ModelContext {
        return dataContainer.mainContext
    }

    // MARK: - Published Properties
    @Published var wordBooks: [WordBook] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private init() {
        loadWordBooks()
    }

    // MARK: - WordBook Management

    /// 创建或获取单词本（以天为唯一键）
    /// - Parameter date: 目标日期，默认为今天
    /// - Returns: 单词本实例
    func getOrCreateWordBook(for date: Date = Date()) -> WordBook {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let wordBook = dataContainer.getOrCreateWordBook(for: date)
            loadWordBooks() // 刷新列表
            print("✅ Successfully got/created WordBook for \(wordBook.formattedDateString)")
            return wordBook
        } catch {
            errorMessage = "创建单词本失败: \(error.localizedDescription)"
            print("❌ Failed to get/create WordBook: \(error)")
            // 发生错误时返回一个临时的单词本
            return WordBook(recordDate: date)
        }
    }

    /// 获取单词本列表
    /// - Parameters:
    ///   - limit: 限制返回数量，默认为 nil（不限制）
    ///   - sortOrder: 排序方式，默认按日期降序
    /// - Returns: 单词本列表
    func getWordBooks(limit: Int? = nil, sortOrder: WordBookSortOrder = .dateDescending) -> [WordBook] {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            var descriptor = FetchDescriptor<WordBook>()
            descriptor.sortBy = [sortOrder.sortDescriptor]

            if let limit = limit {
                descriptor.fetchLimit = limit
            }

            let wordBooks = try context.fetch(descriptor)
            self.wordBooks = wordBooks
            print("✅ Successfully fetched \(wordBooks.count) word books")
            return wordBooks
        } catch {
            errorMessage = "获取单词本列表失败: \(error.localizedDescription)"
            print("❌ Failed to fetch word books: \(error)")
            return []
        }
    }

    /// 根据日期范围获取单词本
    /// - Parameters:
    ///   - startDate: 开始日期
    ///   - endDate: 结束日期
    /// - Returns: 指定日期范围内的单词本列表
    func getWordBooks(from startDate: Date, to endDate: Date) -> [WordBook] {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let predicate = WordBook.predicate(from: startDate, to: endDate)
            let descriptor = FetchDescriptor<WordBook>(
                predicate: predicate,
                sortBy: [SortDescriptor(\WordBook.recordDate, order: .reverse)]
            )

            let wordBooks = try context.fetch(descriptor)
            print("✅ Successfully fetched \(wordBooks.count) word books from date range")
            return wordBooks
        } catch {
            errorMessage = "获取日期范围内单词本失败: \(error.localizedDescription)"
            print("❌ Failed to fetch word books from date range: \(error)")
            return []
        }
    }

    /// 删除单词本
    /// - Parameter wordBook: 要删除的单词本
    /// - Returns: 是否删除成功
    func deleteWordBook(_ wordBook: WordBook) -> Bool {
        do {
            context.delete(wordBook)
            try context.save()
            loadWordBooks() // 刷新列表
            print("✅ Successfully deleted WordBook: \(wordBook.formattedDateString)")
            return true
        } catch {
            errorMessage = "删除单词本失败: \(error.localizedDescription)"
            print("❌ Failed to delete WordBook: \(error)")
            return false
        }
    }

    // MARK: - Word Management

    /// 创建单词
    /// - Parameters:
    ///   - image: 处理后的照片
    ///   - targetLanguage: 目标语言
    ///   - word: 识别出的单词
    ///   - wordBook: 所属单词本，默认为今天的单词本
    /// - Returns: 创建的单词实例，失败返回 nil
    func createWord(
        image: UIImage,
        targetLanguage: String,
        word: String,
        wordBook: WordBook? = nil
    ) -> WordModel? {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            // 如果没有指定单词本，使用今天的单词本
            let targetWordBook = wordBook ?? getOrCreateWordBook()

            // 创建单词（自动缩放图片）
            let newWord = WordModel.createWithImage(
                image,
                targetLanguage: targetLanguage,
                word: word,
                wordBook: targetWordBook
            )

            context.insert(newWord)
            try context.save()

            // 刷新单词本列表以显示最新数据
            loadWordBooks()

            print("✅ Successfully created word: '\(word)' in WordBook: \(targetWordBook.formattedDateString)")
            return newWord
        } catch {
            errorMessage = "创建单词失败: \(error.localizedDescription)"
            print("❌ Failed to create word: \(error)")
            return nil
        }
    }

    /// 根据单词本 ID 获取单词列表
    /// - Parameters:
    ///   - wordBookId: 单词本 ID
    ///   - sortOrder: 排序方式，默认按创建时间降序
    /// - Returns: 单词列表
    func getWords(forWordBookId wordBookId: UUID, sortOrder: WordSortOrder = .createdDateDescending) -> [WordModel] {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let predicate = WordModel.predicate(forWordBookId: wordBookId)
            let descriptor = FetchDescriptor<WordModel>(
                predicate: predicate,
                sortBy: [sortOrder.sortDescriptor]
            )

            let words = try context.fetch(descriptor)
            print("✅ Successfully fetched \(words.count) words for WordBook ID: \(wordBookId)")
            return words
        } catch {
            errorMessage = "获取单词列表失败: \(error.localizedDescription)"
            print("❌ Failed to fetch words for WordBook ID \(wordBookId): \(error)")
            return []
        }
    }

    /// 根据日期获取单词列表
    /// - Parameters:
    ///   - date: 目标日期
    ///   - sortOrder: 排序方式，默认按创建时间降序
    /// - Returns: 指定日期的单词列表
    func getWords(forDate date: Date, sortOrder: WordSortOrder = .createdDateDescending) -> [WordModel] {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let predicate = WordModel.predicate(forDate: date)
            let descriptor = FetchDescriptor<WordModel>(
                predicate: predicate,
                sortBy: [sortOrder.sortDescriptor]
            )

            let words = try context.fetch(descriptor)
            print("✅ Successfully fetched \(words.count) words for date: \(date.startOfDay)")
            return words
        } catch {
            errorMessage = "获取指定日期单词列表失败: \(error.localizedDescription)"
            print("❌ Failed to fetch words for date \(date): \(error)")
            return []
        }
    }

    /// 更新单词掌握程度
    /// - Parameters:
    ///   - word: 要更新的单词
    ///   - masteryLevel: 新的掌握程度 (0-5)
    /// - Returns: 是否更新成功
    func updateWordMasteryLevel(_ word: WordModel, to masteryLevel: Int) -> Bool {
        do {
            word.setMasteryLevel(masteryLevel)
            try context.save()
            print("✅ Successfully updated mastery level for word: '\(word.word)' to \(masteryLevel)")
            return true
        } catch {
            errorMessage = "更新单词掌握程度失败: \(error.localizedDescription)"
            print("❌ Failed to update word mastery level: \(error)")
            return false
        }
    }

    /// 删除单词
    /// - Parameter word: 要删除的单词
    /// - Returns: 是否删除成功
    func deleteWord(_ word: WordModel) -> Bool {
        do {
            context.delete(word)
            try context.save()
            loadWordBooks() // 刷新单词本列表
            print("✅ Successfully deleted word: '\(word.word)'")
            return true
        } catch {
            errorMessage = "删除单词失败: \(error.localizedDescription)"
            print("❌ Failed to delete word: \(error)")
            return false
        }
    }

    // MARK: - Search and Filter

    /// 搜索单词
    /// - Parameters:
    ///   - searchText: 搜索文本
    ///   - wordBookId: 限制搜索范围到特定单词本，可选
    /// - Returns: 匹配的单词列表
    func searchWords(_ searchText: String, inWordBookId wordBookId: UUID? = nil) -> [WordModel] {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            var descriptor: FetchDescriptor<WordModel>

            if let wordBookId = wordBookId {
                // 使用复合谓词，同时满足搜索条件和单词本ID条件
                descriptor = FetchDescriptor<WordModel>(
                    predicate: #Predicate<WordModel> { word in
                        (word.word.contains(searchText) || word.notes.contains(searchText)) &&
                        word.wordBook?.id == wordBookId
                    },
                    sortBy: [SortDescriptor(\WordModel.createdAt, order: .reverse)]
                )
            } else {
                // 仅搜索条件
                descriptor = FetchDescriptor<WordModel>(
                    predicate: #Predicate<WordModel> { word in
                        word.word.contains(searchText) || word.notes.contains(searchText)
                    },
                    sortBy: [SortDescriptor(\WordModel.createdAt, order: .reverse)]
                )
            }

            let words = try context.fetch(descriptor)
            print("✅ Successfully searched \(words.count) words for '\(searchText)'")
            return words
        } catch {
            errorMessage = "搜索单词失败: \(error.localizedDescription)"
            print("❌ Failed to search words: \(error)")
            return []
        }
    }

    // MARK: - Learning Plan Management

    /// 获取今日需要复习的单词列表
    /// - Parameter limit: 限制返回数量，默认为20个
    /// - Returns: 今日需要复习的单词列表
    func getTodayReviewWords(limit: Int = 20) -> [WordModel] {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let predicate = WordModel.predicate(needsReview: true)
            var descriptor = FetchDescriptor<WordModel>(
                predicate: predicate,
                sortBy: [WordModel.sortByNextReviewDateAscending]
            )

            if limit > 0 {
                descriptor.fetchLimit = limit
            }

            let words = try context.fetch(descriptor)
            print("✅ Successfully fetched \(words.count) words for today's review")
            return words
        } catch {
            errorMessage = "获取今日复习单词失败: \(error.localizedDescription)"
            print("❌ Failed to fetch today's review words: \(error)")
            return []
        }
    }

    /// 标记单词复习状态并自动计算下次复习时间
    /// - Parameters:
    ///   - word: 要标记复习状态的单词
    ///   - correct: 是否答对
    /// - Returns: 是否标记成功
    func markWordReviewed(_ word: WordModel, correct: Bool) -> Bool {
        do {
            // 调用单词自身的复习方法
            word.markAsReviewed(correct: correct)

            // 保存到数据库
            try context.save()

            let result = correct ? "正确" : "错误"
            print("✅ Successfully marked word '\(word.word)' as reviewed (\(result))")
            return true
        } catch {
            errorMessage = "标记单词复习状态失败: \(error.localizedDescription)"
            print("❌ Failed to mark word as reviewed: \(error)")
            return false
        }
    }

    /// 批量标记多个单词的复习状态
    /// - Parameters:
    ///   - reviewResults: 复习结果数组，格式为 [(word: WordModel, correct: Bool)]
    /// - Returns: 成功标记的单词数量
    func markWordsReviewed(_ reviewResults: [(word: WordModel, correct: Bool)]) -> Int {
        var successCount = 0

        for result in reviewResults {
            if markWordReviewed(result.word, correct: result.correct) {
                successCount += 1
            }
        }

        print("✅ Successfully marked \(successCount)/\(reviewResults.count) words as reviewed")
        return successCount
    }

    /// 自动更新所有单词的学习计划（当复习算法发生变化时使用）
    /// - Returns: 更新的单词数量
    func updateAllLearningPlans() -> Int {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            // 获取所有单词
            let descriptor = FetchDescriptor<WordModel>()
            let allWords = try context.fetch(descriptor)

            var updatedCount = 0

            for word in allWords {
                // 根据当前的掌握程度和复习次数重新计算复习间隔
                let newInterval = calculateOptimalReviewInterval(for: word)

                if word.reviewInterval != newInterval {
                    word.reviewInterval = newInterval

                    // 重新计算下次复习日期
                    let now = Date()
                    if newInterval == 0 {
                        word.nextReviewDate = Calendar.current.date(byAdding: .hour, value: 4, to: now) ?? now
                    } else {
                        word.nextReviewDate = Calendar.current.date(byAdding: .day, value: newInterval, to: now) ?? now
                    }

                    word.updatedAt = now
                    updatedCount += 1
                }
            }

            if updatedCount > 0 {
                try context.save()
                print("✅ Successfully updated learning plans for \(updatedCount) words")
            } else {
                print("ℹ️ No learning plans needed updating")
            }

            return updatedCount
        } catch {
            errorMessage = "更新学习计划失败: \(error.localizedDescription)"
            print("❌ Failed to update learning plans: \(error)")
            return 0
        }
    }

    /// 根据单词当前状态计算最优复习间隔
    /// - Parameter word: 要计算的单词
    /// - Returns: 推荐的复习间隔（天数）
    private func calculateOptimalReviewInterval(for word: WordModel) -> Int {
        // 基于掌握程度和复习次数计算间隔
        let baseInterval = min(word.reviewCount, WordModel.reviewIntervals.count - 1)
        let masteryBonus = word.masteryLevel / 2 // 掌握程度高的可以延长间隔

        let adjustedInterval = min(baseInterval + masteryBonus, WordModel.reviewIntervals.count - 1)
        return WordModel.reviewIntervals[adjustedInterval]
    }

    // MARK: - Private Methods

    /// 加载单词本列表
    private func loadWordBooks() {
        wordBooks = getWordBooks()
    }
}

// MARK: - Review Statistics

/// 复习统计数据
struct ReviewStatistics {
    let todayReviewCount: Int          // 今日复习数量
    let correctCount: Int              // 正确数量
    let incorrectCount: Int            // 错误数量
    let accuracyRate: Double           // 正确率
    let pendingReviewCount: Int        // 待复习数量
    let totalWordsCount: Int           // 总单词数量
    let masteredWordsCount: Int        // 已掌握单词数量（掌握程度 >= 4）

    var formattedAccuracyRate: String {
        return String(format: "%.1f%%", accuracyRate * 100)
    }
}

extension WordBookManager {

    /// 获取复习统计数据
    /// - Returns: 复习统计数据
    func getReviewStatistics() -> ReviewStatistics {
        do {
            let today = Date()
            let startOfToday = Calendar.current.startOfDay(for: today)
            let endOfToday = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!

            // 获取今天复习过的单词（通过上次复习日期判断）
            // 使用两个简单的predicate分别处理有复习日期和没有复习日期的单词
            let predicateWithReviewDate = #Predicate<WordModel> { word in
                word.lastReviewDate != nil &&
                word.lastReviewDate! >= startOfToday &&
                word.lastReviewDate! < endOfToday
            }
            let todayReviewedDescriptor = FetchDescriptor<WordModel>(
                predicate: predicateWithReviewDate
            )
            let todayReviewedWords = try context.fetch(todayReviewedDescriptor)

            // 统计正确和错误数量（通过掌握程度变化判断）
            var correctCount = 0
            var incorrectCount = 0

            for word in todayReviewedWords {
                // 简化统计：掌握程度 >= 3 的认为答对较多，否则认为答错较多
                // 这是一个简化统计，实际项目中可以记录更详细的复习历史
                if word.masteryLevel >= 3 {
                    correctCount += 1
                } else {
                    incorrectCount += 1
                }
            }

            // 获取待复习数量
            let pendingDescriptor = FetchDescriptor<WordModel>(
                predicate: WordModel.predicate(needsReview: true)
            )
            let pendingWords = try context.fetch(pendingDescriptor)

            // 获取总单词数量
            let totalDescriptor = FetchDescriptor<WordModel>()
            let totalWords = try context.fetch(totalDescriptor)

            // 获取已掌握单词数量
            let masteredDescriptor = FetchDescriptor<WordModel>(
                predicate: WordModel.predicate(masteryLevelGreaterOrEqual: 4)
            )
            let masteredWords = try context.fetch(masteredDescriptor)

            let totalReviewed = correctCount + incorrectCount
            let accuracyRate = totalReviewed > 0 ? Double(correctCount) / Double(totalReviewed) : 0.0

            return ReviewStatistics(
                todayReviewCount: todayReviewedWords.count,
                correctCount: correctCount,
                incorrectCount: incorrectCount,
                accuracyRate: accuracyRate,
                pendingReviewCount: pendingWords.count,
                totalWordsCount: totalWords.count,
                masteredWordsCount: masteredWords.count
            )

        } catch {
            print("❌ Failed to get review statistics: \(error)")
            return ReviewStatistics(
                todayReviewCount: 0,
                correctCount: 0,
                incorrectCount: 0,
                accuracyRate: 0.0,
                pendingReviewCount: 0,
                totalWordsCount: 0,
                masteredWordsCount: 0
            )
        }
    }

    /// 获取未来几天的复习计划
    /// - Parameter days: 未来天数，默认7天
    /// - Returns: 按日期分组的复习计划 [日期: 单词数量]
    func getUpcomingReviewPlan(days: Int = 7) -> [String: Int] {
        var reviewPlan: [String: Int] = [:]

        do {
            let startDate = Date()
            let endDate = Calendar.current.date(byAdding: .day, value: days, to: startDate)!

            let predicate = WordModel.predicate(reviewDateInRange: startDate, endDate)
            let descriptor = FetchDescriptor<WordModel>(
                predicate: predicate,
                sortBy: [WordModel.sortByNextReviewDateAscending]
            )

            let words = try context.fetch(descriptor)
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd"

            for word in words {
                let dateString = formatter.string(from: word.nextReviewDate)
                reviewPlan[dateString, default: 0] += 1
            }

            print("✅ Successfully generated review plan for next \(days) days")

        } catch {
            print("❌ Failed to generate review plan: \(error)")
        }

        return reviewPlan
    }
}

// MARK: - Sort Orders

/// 单词本排序方式
enum WordBookSortOrder {
    case dateDescending  // 按日期降序（最新的在前）
    case dateAscending   // 按日期升序（最旧的在前）
    case wordCountDescending  // 按单词数量降序
    case wordCountAscending   // 按单词数量升序

    var sortDescriptor: SortDescriptor<WordBook> {
        switch self {
        case .dateDescending:
            return SortDescriptor(\WordBook.recordDate, order: .reverse)
        case .dateAscending:
            return SortDescriptor(\WordBook.recordDate, order: .forward)
        case .wordCountDescending:
            return SortDescriptor(\WordBook.wordCount, order: .reverse)
        case .wordCountAscending:
            return SortDescriptor(\WordBook.wordCount, order: .forward)
        }
    }
}

/// 单词排序方式
enum WordSortOrder {
    case createdDateDescending  // 按创建时间降序
    case createdDateAscending   // 按创建时间升序
    case wordAlphabetically     // 按单词字母顺序
    case masteryLevelAscending  // 按掌握程度升序
    case masteryLevelDescending // 按掌握程度降序

    var sortDescriptor: SortDescriptor<WordModel> {
        switch self {
        case .createdDateDescending:
            return WordModel.sortByCreatedDateDescending
        case .createdDateAscending:
            return SortDescriptor(\WordModel.createdAt, order: .forward)
        case .wordAlphabetically:
            return WordModel.sortByWordAlphabetically
        case .masteryLevelAscending:
            return WordModel.sortByMasteryLevelAscending
        case .masteryLevelDescending:
            return SortDescriptor(\WordModel.masteryLevel, order: .reverse)
        }
    }
}