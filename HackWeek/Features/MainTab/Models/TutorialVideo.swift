//
//  TutorialVideo.swift
//  HackWords
//
//  Created by Claude on 2025/10/20.
//

import Foundation

/// 教程标签
enum TutorialTag: String, Codable, CaseIterable {
    // 难度级别
    case beginner = "Beginner"
    case advanced = "Advanced"
    
    // 妆容类型
    case everyday = "Everyday"
    case naturalLook = "Natural Look"
    case eyeMakeup = "Eye Makeup"
    case glamorous = "Glamorous"
    case smokyEye = "Smoky Eye"
    case contouring = "Contouring"
    case highlighting = "Highlighting"
    
    // 快速技巧
    case quickTips = "Quick Tips"
    case stepByStep = "Step by Step"
    case professional = "Professional"
}

/// 视频教程数据模型
struct TutorialVideo: Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String?
    let thumbnailURL: String
    let videoUrl: String
    let duration: TimeInterval?
    let tags: [String]
    
    init(id: String = UUID().uuidString,
         title: String,
         summary: String? = nil,
         thumbnailURL: String,
         videoUrl: String,
         duration: TimeInterval? = nil,
         tags: [String] = []) {
        self.id = id
        self.title = title
        self.summary = summary
        self.thumbnailURL = thumbnailURL
        self.videoUrl = videoUrl
        self.duration = duration
        self.tags = tags
    }
}

// MARK: - Helper Extensions

extension TutorialVideo {
    /// 格式化时长显示
    var formattedDuration: String? {
        guard let duration = duration else { return nil }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// 是否为初级教程
    var isBeginner: Bool {
        return tags.contains(TutorialTag.beginner.rawValue)
    }
    
    /// 是否为高级教程
    var isAdvanced: Bool {
        return tags.contains(TutorialTag.advanced.rawValue)
    }
    
    /// 获取所有标签枚举
    var tutorialTags: [TutorialTag] {
        return tags.compactMap { TutorialTag(rawValue: $0) }
    }
}

