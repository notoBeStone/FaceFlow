//
//  WordBook.swift
//  HackWeek
//
//  Created by Stephen on 2025/10/14.
//

import Foundation
import SwiftData

@Model
final class WordBook {
    // MARK: - Properties
    /// 单词本唯一标识符
    @Attribute(.unique) var id: UUID

    /// 记录日期（以天为单位）
    @Attribute(.unique) var recordDate: Date

    /// 创建时间
    var createdAt: Date

    /// 更新时间
    var updatedAt: Date

    /// 该单词本包含的所有单词
    @Relationship(deleteRule: .cascade, inverse: \WordModel.wordBook)
    var words: [WordModel] = []

    // MARK: - Initializer
    init(recordDate: Date) {
        self.id = UUID()
        self.recordDate = recordDate.startOfDay
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties
    /// 单词本中单词的数量
    var wordCount: Int {
        return words.count
    }

    /// 已掌握单词的数量（掌握等级 >= 4）
    var masteredWordCount: Int {
        return words.filter { $0.masteryLevel >= 4 }.count
    }

    /// 格式化的日期字符串（YYYY-MM-DD）
    var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: recordDate)
    }

    /// 友好的日期显示（如："今天"、"昨天"、"2025年10月14日"）
    var friendlyDateDisplay: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        if recordDate == today {
            return "今天"
        } else if recordDate == yesterday {
            return "昨天"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年M月d日"
            return formatter.string(from: recordDate)
        }
    }

    // MARK: - Methods
    /// 添加单词到单词本
    func addWord(_ word: WordModel) {
        words.append(word)
        word.wordBook = self
        updatedAt = Date()
    }

    /// 移除单词
    func removeWord(_ word: WordModel) {
        words.removeAll { $0.id == word.id }
        updatedAt = Date()
    }
}

// MARK: - Date Extension
extension Date {
    /// 获取日期的开始部分（00:00:00）
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}

// MARK: - WordBook Extensions for SwiftData Queries
extension WordBook {
    /// 根据日期获取单词本
    static func predicate(forDate date: Date) -> Predicate<WordBook> {
        let startOfDay = date.startOfDay
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        return #Predicate<WordBook> { wordBook in
            wordBook.recordDate >= startOfDay && wordBook.recordDate < endOfDay
        }
    }

    /// 获取指定日期范围内的单词本
    static func predicate(from startDate: Date, to endDate: Date) -> Predicate<WordBook> {
        let start = startDate.startOfDay
        let end = Calendar.current.date(byAdding: .day, value: 1, to: endDate.startOfDay)!
        return #Predicate<WordBook> { wordBook in
            wordBook.recordDate >= start && wordBook.recordDate < end
        }
    }
}