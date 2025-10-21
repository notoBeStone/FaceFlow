//
//  WordModel.swift
//  HackWeek
//
//  Created by Stephen on 2025/10/14.
//

import Foundation
import SwiftData
import UIKit

@Model
final class WordModel {
    // MARK: - Properties
    /// 单词唯一标识符
    @Attribute(.unique) var id: UUID

    /// 处理后的照片数据（base64 编码，已缩放至 320x320 像素以内）
    var imageData: Data

    /// 目标语言
    var targetLanguage: String

    /// 记录日期
    var recordDate: Date

    /// 识别出的单词
    var word: String

    /// 创建时间
    var createdAt: Date

    /// 更新时间
    var updatedAt: Date

    /// 所属的单词本（多对一关系）
    @Relationship
    var wordBook: WordBook?

    /// 单词掌握程度（0-5，0: 未学习，5: 完全掌握）
    var masteryLevel: Int

    /// 单词备注
    var notes: String

    // MARK: - Learning Plan Properties
    /// 下次复习日期
    var nextReviewDate: Date

    /// 当前复习间隔（天数）
    var reviewInterval: Int

    /// 上次复习日期
    var lastReviewDate: Date?

    /// 复习次数
    var reviewCount: Int

    /// 是否需要复习（基于当前日期和下次复习日期）
    var needsReview: Bool {
        return Calendar.current.isDateInToday(nextReviewDate) || nextReviewDate <= Date()
    }

    // MARK: - Initializer
    init(imageData: Data, targetLanguage: String, word: String, wordBook: WordBook? = nil) {
        self.id = UUID()
        self.imageData = imageData
        self.targetLanguage = targetLanguage
        self.word = word
        self.recordDate = Date().startOfDay
        self.createdAt = Date()
        self.updatedAt = Date()
        self.wordBook = wordBook
        self.masteryLevel = 0
        self.notes = ""

        // 初始化学习计划字段
        self.nextReviewDate = Date() // 新单词今天就可以复习
        self.reviewInterval = 0      // 新单词从0间隔开始
        self.lastReviewDate = nil    // 还没有复习过
        self.reviewCount = 0         // 复习次数为0

        // 如果有单词本，自动建立关系
        if let wordBook = wordBook {
            wordBook.addWord(self)
        }
    }

    // MARK: - Computed Properties
    /// 图片的 base64 字符串表示
    var base64ImageString: String {
        return imageData.base64EncodedString()
    }

    /// 是否为今天创建的单词
    var isCreatedToday: Bool {
        return Calendar.current.isDateInToday(createdAt)
    }

    /// 掌握程度的文字描述
    var masteryLevelDescription: String {
        switch masteryLevel {
        case 0: return "未学习"
        case 1: return "初识"
        case 2: return "熟悉"
        case 3: return "掌握"
        case 4: return "熟练"
        case 5: return "精通"
        default: return "未知"
        }
    }

    /// 格式化的创建时间字符串
    var formattedCreatedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: createdAt)
    }

    // MARK: - Image Processing
    /// 从 UIImage 创建 WordModel（自动缩放至 320x320 以内）
    static func createWithImage(
        _ image: UIImage,
        targetLanguage: String,
        word: String,
        wordBook: WordBook? = nil
    ) -> WordModel {
        let scaledImageData = WordModel.scaleImageToSize(image, maxSize: 320)
        return WordModel(
            imageData: scaledImageData,
            targetLanguage: targetLanguage,
            word: word,
            wordBook: wordBook
        )
    }

    /// 缩放图片到指定尺寸以内，保持宽高比
    private static func scaleImageToSize(_ image: UIImage, maxSize: CGFloat) -> Data {
        let originalSize = image.size
        let maxDimension = max(originalSize.width, originalSize.height)

        // 如果图片尺寸已经在限制内，直接返回原图数据
        if maxDimension <= maxSize {
            return image.jpegData(compressionQuality: 0.8) ?? Data()
        }

        // 计算缩放比例
        let scale = maxSize / maxDimension
        let newSize = CGSize(
            width: originalSize.width * scale,
            height: originalSize.height * scale
        )

        // 缩放图片
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage?.jpegData(compressionQuality: 0.8) ?? Data()
    }

    /// 获取 UIImage（从 base64 数据）
    var uiImage: UIImage? {
        return UIImage(data: imageData)
    }

    // MARK: - Learning Progress Methods
    /// 提升掌握程度
    func increaseMasteryLevel() {
        if masteryLevel < 5 {
            masteryLevel += 1
            updatedAt = Date()
        }
    }

    /// 降低掌握程度
    func decreaseMasteryLevel() {
        if masteryLevel > 0 {
            masteryLevel -= 1
            updatedAt = Date()
        }
    }

    /// 设置掌握程度
    func setMasteryLevel(_ level: Int) {
        masteryLevel = max(0, min(5, level))
        updatedAt = Date()
    }

    /// 更新备注
    func updateNotes(_ newNotes: String) {
        notes = newNotes
        updatedAt = Date()
    }

    /// 移动到另一个单词本
    func moveToWordBook(_ newWordBook: WordBook) {
        // 从当前单词本移除
        wordBook?.removeWord(self)

        // 添加到新单词本
        newWordBook.addWord(self)
        updatedAt = Date()
    }

    // MARK: - Learning Plan Methods
    /// 简化版遗忘曲线复习间隔：1天、2天、4天、7天、15天
    static let reviewIntervals = [0, 1, 2, 4, 7, 15] // 0表示当天复习

    /// 获取下一个复习间隔
    static func getNextReviewInterval(after currentInterval: Int) -> Int {
        guard let currentIndex = reviewIntervals.firstIndex(of: currentInterval) else {
            return reviewIntervals[1] // 默认返回1天
        }

        let nextIndex = min(currentIndex + 1, reviewIntervals.count - 1)
        return reviewIntervals[nextIndex]
    }

    /// 标记单词已复习并自动计算下次复习时间
    /// - Parameter correct: 是否答对，答对时提升掌握程度和复习间隔，答错时重置间隔
    func markAsReviewed(correct: Bool) {
        let now = Date()
        lastReviewDate = now
        reviewCount += 1
        updatedAt = now

        if correct {
            // 答对了，提升掌握程度和复习间隔
            if masteryLevel < 5 {
                masteryLevel += 1
            }

            // 计算下一个复习间隔
            let nextInterval = WordModel.getNextReviewInterval(after: reviewInterval)
            reviewInterval = nextInterval

            // 计算下次复习日期
            if nextInterval == 0 {
                // 间隔为0，表示今天再复习一次
                nextReviewDate = Calendar.current.date(byAdding: .hour, value: 4, to: now) ?? now
            } else {
                // 间隔大于0，按天数计算
                nextReviewDate = Calendar.current.date(byAdding: .day, value: nextInterval, to: now) ?? now
            }

            print("✅ Word '\(word)' reviewed correctly. Next review in \(nextInterval) days.")
        } else {
            // 答错了，降低掌握程度，重置复习间隔
            if masteryLevel > 0 {
                masteryLevel = max(0, masteryLevel - 1)
            }

            // 重置为初始复习间隔（1天）
            reviewInterval = 1
            nextReviewDate = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now

            print("❌ Word '\(word)' reviewed incorrectly. Reset to 1 day interval.")
        }
    }

    /// 获取复习状态的描述
    var reviewStatusDescription: String {
        if needsReview {
            return "需要复习"
        } else {
            let daysUntilReview = Calendar.current.dateComponents([.day], from: Date(), to: nextReviewDate).day ?? 0
            if daysUntilReview == 0 {
                return "今天复习"
            } else if daysUntilReview == 1 {
                return "明天复习"
            } else {
                return "\(daysUntilReview)天后复习"
            }
        }
    }

    /// 获取格式化的下次复习日期
    var formattedNextReviewDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter.string(from: nextReviewDate)
    }
}

// MARK: - WordModel Extensions for SwiftData Queries
extension WordModel {
    /// 根据单词本 ID 获取单词
    static func predicate(forWordBookId wordBookId: UUID) -> Predicate<WordModel> {
        return #Predicate<WordModel> { wordModel in
            wordModel.wordBook?.id == wordBookId
        }
    }

    /// 根据日期获取单词
    static func predicate(forDate date: Date) -> Predicate<WordModel> {
        let startOfDay = date.startOfDay
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        return #Predicate<WordModel> { wordModel in
            wordModel.recordDate >= startOfDay && wordModel.recordDate < endOfDay
        }
    }

    /// 根据掌握程度获取单词
    static func predicate(forMasteryLevel level: Int) -> Predicate<WordModel> {
        return #Predicate<WordModel> { wordModel in
            wordModel.masteryLevel == level
        }
    }

    /// 根据目标语言获取单词
    static func predicate(forTargetLanguage language: String) -> Predicate<WordModel> {
        return #Predicate<WordModel> { wordModel in
            wordModel.targetLanguage == language
        }
    }

    /// 搜索包含特定文字的单词
    static func predicate(searchText text: String) -> Predicate<WordModel> {
        return #Predicate<WordModel> { wordModel in
            wordModel.word.contains(text) || wordModel.notes.contains(text)
        }
    }

    /// 获取需要复习的单词
    static func predicate(needsReview: Bool = true) -> Predicate<WordModel> {
        let today = Date()
        let startOfToday = Calendar.current.startOfDay(for: today)
        let endOfToday = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!

        return #Predicate<WordModel> { wordModel in
            wordModel.nextReviewDate >= startOfToday && wordModel.nextReviewDate < endOfToday
        }
    }

    /// 根据复习日期范围获取单词
    static func predicate(reviewDateInRange startDate: Date, _ endDate: Date) -> Predicate<WordModel> {
        let start = Calendar.current.startOfDay(for: startDate)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: endDate))!

        return #Predicate<WordModel> { wordModel in
            wordModel.nextReviewDate >= start && wordModel.nextReviewDate < end
        }
    }

    /// 根据掌握程度获取单词
    static func predicate(masteryLevelGreaterOrEqual level: Int) -> Predicate<WordModel> {
        return #Predicate<WordModel> { wordModel in
            wordModel.masteryLevel >= level
        }
    }
}

// MARK: - Sort Descriptors
extension WordModel {
    /// 按创建时间降序排序
    static var sortByCreatedDateDescending: SortDescriptor<WordModel> {
        return SortDescriptor(\WordModel.createdAt, order: .reverse)
    }

    /// 按掌握程度升序排序
    static var sortByMasteryLevelAscending: SortDescriptor<WordModel> {
        return SortDescriptor(\WordModel.masteryLevel, order: .forward)
    }

    /// 按单词字母顺序排序
    static var sortByWordAlphabetically: SortDescriptor<WordModel> {
        return SortDescriptor(\WordModel.word, order: .forward)
    }

    /// 按下次复习时间升序排序（最需要复习的在前）
    static var sortByNextReviewDateAscending: SortDescriptor<WordModel> {
        return SortDescriptor(\WordModel.nextReviewDate, order: .forward)
    }

    /// 按复习次数降序排序
    static var sortByReviewCountDescending: SortDescriptor<WordModel> {
        return SortDescriptor(\WordModel.reviewCount, order: .reverse)
    }

    /// 按复习间隔升序排序
    static var sortByReviewIntervalAscending: SortDescriptor<WordModel> {
        return SortDescriptor(\WordModel.reviewInterval, order: .forward)
    }
}