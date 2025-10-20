//
//  OnboardingData.swift
//  HackWords
//
//  Created by Claude on 2025/10/13.
//

import Foundation

/// Onboarding用户数据模型
struct OnboardingData: Codable {
    /// 用户选择的年龄段
    let ageGroup: String

    /// 用户选择的目标语言
    let targetLanguage: String

    /// 数据创建时间
    let createdAt: Date

    /// 是否已完成onboarding流程
    let isCompleted: Bool

    init(ageGroup: String, targetLanguage: String, isCompleted: Bool = false) {
        self.ageGroup = ageGroup
        self.targetLanguage = targetLanguage
        self.createdAt = Date()
        self.isCompleted = isCompleted
    }
}

/// 年龄段枚举
enum OnboardingAgeGroup: String, CaseIterable {
    case under18 = "<18"
    case age18to25 = "18-25"
    case age25to35 = "25-35"
    case age35to55 = "35-55"
    case over55 = "55+"

    var displayText: String {
        return self.rawValue
    }
}

/// 目标语言枚举
enum OnboardingLanguage: String, CaseIterable {
    case spanish = "Spanish"
    case chinese = "中文"
    case japanese = "日本語"

    var displayText: String {
        return self.rawValue
    }

    var languageCode: String {
        switch self {
        case .spanish:
            return "es"
        case .chinese:
            return "zh"
        case .japanese:
            return "ja"
        }
    }
}