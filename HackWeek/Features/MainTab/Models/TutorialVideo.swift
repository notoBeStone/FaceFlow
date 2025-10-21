//
//  TutorialVideo.swift
//  HackWords
//
//  Created by Claude on 2025/10/20.
//

import Foundation

/// 教程标签
enum TutorialTag: String, Codable, CaseIterable {
    // MARK: - Difficulty Level
    case beginner = "Beginner"
    case advanced = "Advanced"
    
    // MARK: - Face Structure
    case round = "Round"                        // 圆形脸
    case oval = "Oval"                          // 椭圆形脸
    case square = "Square"                      // 方形脸
    case oblong = "Oblong"                      // 长形脸
    case heart = "Heart"                        // 心形脸
    case invertedTriangle = "InvertedTriangle"  // 倒三角形脸
    
    // MARK: - Cheekbone Prominence
    case high = "High"                          // 高颧骨
    case normal = "Normal"                      // 正常颧骨
    case low = "Low"                            // 低颧骨
    
    // MARK: - Jawline Type
    case roundJawline = "RoundJawline"          // 圆润下颌线
    case sharpJawline = "SharpJawline"          // 尖锐下颌线
    case squareJawline = "SquareJawline"        // 方形下颌线
    case definedJawline = "DefinedJawline"      // 下颌角明显
    
    // MARK: - Chin Shape
    case pointed = "Pointed"                    // 尖下巴
    case roundChin = "RoundChin"                // 圆下巴
    case wide = "Wide"                          // 宽下巴
    
    // MARK: - Eye Size
    case small = "Small"                        // 小眼睛
    case normalEye = "NormalEye"                // 正常眼睛
    case large = "Large"                        // 大眼睛
    
    // MARK: - Eye Shape
    case monolid = "Monolid"                    // 单眼皮
    case doubleLid = "DoubleLid"                // 双眼皮
    case innerDouble = "InnerDouble"            // 内双
    case puffy = "Puffy"                        // 肿泡眼
    
    // MARK: - Eye Distance
    case wideEye = "WideEye"                    // 眼距宽
    case normalDistance = "NormalDistance"      // 眼距正常
    case narrow = "Narrow"                      // 眼距窄
    
    // MARK: - Eyebrow Shape
    case straight = "Straight"                  // 平眉
    case curved = "Curved"                      // 弯眉
    case arched = "Arched"                      // 拱形眉
    case angular = "Angular"                    // 剑眉
    
    // MARK: - Nose Length
    case short = "Short"                        // 短鼻
    case normalNose = "NormalNose"              // 正常鼻长
    case long = "Long"                          // 长鼻
    
    // MARK: - Nose Width
    case narrowNose = "NarrowNose"              // 窄鼻
    case normalWidth = "NormalWidth"            // 正常鼻宽
    case wideNose = "WideNose"                  // 宽鼻
    
    // MARK: - Lips Thickness
    case thin = "Thin"                          // 薄唇
    case medium = "Medium"                      // 适中唇
    case thick = "Thick"                        // 厚唇
    
    // MARK: - Lips Shape
    case topHeavy = "TopHeavy"                  // 上厚下薄
    case bottomHeavy = "BottomHeavy"            // 下厚上薄
    case balanced = "Balanced"                  // 厚薄均匀
    
    // MARK: - Skin Type
    case dry = "Dry"                            // 干性肤质
    case oily = "Oily"                          // 油性肤质
    case normalSkin = "NormalSkin"              // 中性肤质
    case combination = "Combination"            // 混合肤质
    case sensitive = "Sensitive"                // 敏感肤质
    
    // MARK: - Skin Tone
    case coolFair = "CoolFair"                  // 冷白皮
    case warmFair = "WarmFair"                  // 暖白皮
    case natural = "Natural"                    // 自然肤色
    case healthy = "Healthy"                    // 健康肤色
    case wheat = "Wheat"                        // 小麦肤色
    
    // MARK: - Age Range
    case under18 = "Under18"                    // 18以下
    case age19to25 = "Age19To25"                // 19-25岁
    case age26to35 = "Age26To35"                // 26-35岁
    case age36to45 = "Age36To45"                // 36-45岁
    case over45 = "Over45"                      // 45岁以上
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

