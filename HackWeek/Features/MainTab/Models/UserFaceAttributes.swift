//
//  UserFaceAttributes.swift
//  HackWords
//
//  Created by Claude on 2025/10/21.
//

import Foundation
import SwiftData

// MARK: - Face Structure Enums

/// 脸型
enum FaceShape: String, Codable, CaseIterable {
    case round = "Round"                    // 圆形
    case oval = "Oval"                      // 椭圆形
    case square = "Square"                  // 方形
    case oblong = "Oblong"                  // 长形
    case heart = "Heart"                    // 心形
    case invertedTriangle = "InvertedTriangle"  // 倒三角形
}

/// 颧骨高低
enum CheekboneProminence: String, Codable, CaseIterable {
    case high = "High"                      // 高
    case normal = "Normal"                  // 正常
    case low = "Low"                        // 低
}

/// 下颌线类型
enum JawlineType: String, Codable, CaseIterable {
    case round = "RoundJawline"             // 圆润
    case sharp = "SharpJawline"             // 尖锐
    case square = "SquareJawline"           // 方形
    case defined = "DefinedJawline"         // 下颌角明显
}

/// 下巴形状
enum ChinShape: String, Codable, CaseIterable {
    case pointed = "Pointed"                // 尖
    case round = "RoundChin"                // 圆
    case wide = "Wide"                      // 宽
}

// MARK: - Eye Feature Enums

/// 眼睛大小
enum EyeSize: String, Codable, CaseIterable {
    case small = "Small"                    // 小
    case normal = "NormalEye"               // 正常
    case large = "Large"                    // 大
}

/// 眼睛形状
enum EyeShape: String, Codable, CaseIterable {
    case monolid = "Monolid"                // 单眼皮
    case doubleLid = "DoubleLid"            // 双眼皮
    case innerDouble = "InnerDouble"        // 内双
    case puffy = "Puffy"                    // 肿泡
}

/// 眼距
enum EyeDistance: String, Codable, CaseIterable {
    case wide = "WideEye"                   // 宽
    case normal = "NormalDistance"          // 正常
    case narrow = "Narrow"                  // 窄
}

/// 眉形
enum EyebrowShape: String, Codable, CaseIterable {
    case straight = "Straight"              // 平
    case curved = "Curved"                  // 弯
    case arched = "Arched"                  // 拱形
    case angular = "Angular"                // 剑眉
}

// MARK: - Nose Feature Enums

/// 鼻子长度
enum NoseLength: String, Codable, CaseIterable {
    case short = "Short"                    // 短
    case normal = "NormalNose"              // 正常
    case long = "Long"                      // 长
}

/// 鼻子宽度
enum NoseWidth: String, Codable, CaseIterable {
    case narrow = "NarrowNose"              // 窄
    case normal = "NormalWidth"             // 正常
    case wide = "WideNose"                  // 宽
}

// MARK: - Lips Feature Enums

/// 嘴唇厚度
enum LipsThickness: String, Codable, CaseIterable {
    case thin = "Thin"                      // 薄
    case medium = "Medium"                  // 适中
    case thick = "Thick"                    // 厚
}

/// 嘴唇形状
enum LipsShape: String, Codable, CaseIterable {
    case topHeavy = "TopHeavy"              // 上厚下薄
    case bottomHeavy = "BottomHeavy"        // 下厚上薄
    case balanced = "Balanced"              // 厚薄均匀
}

// MARK: - Skin Feature Enums

/// 肤质
enum SkinType: String, Codable, CaseIterable {
    case dry = "Dry"                        // 干性
    case oily = "Oily"                      // 油性
    case normal = "NormalSkin"              // 中性
    case combination = "Combination"        // 混合
    case sensitive = "Sensitive"            // 敏感
}

/// 肤色
enum SkinTone: String, Codable, CaseIterable {
    case coolFair = "CoolFair"              // 冷白
    case warmFair = "WarmFair"              // 暖白
    case natural = "Natural"                // 自然
    case healthy = "Healthy"                // 健康
    case wheat = "Wheat"                    // 小麦色
}

// MARK: - Age Range Enum

/// 年龄范围
enum AgeRange: String, Codable, CaseIterable {
    case under18 = "Under18"                // 18以下
    case age19to25 = "Age19To25"            // 19-25
    case age26to35 = "Age26To35"            // 26-35
    case age36to45 = "Age36To45"            // 36-45
    case over45 = "Over45"                  // 45以上
}

// MARK: - User Face Attributes Model

/// 用户面部和皮肤属性模型
@Model
final class UserFaceAttributes {
    // MARK: - Core Properties
    
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date
    
    // MARK: - Face Structure
    
    /// 脸型
    var faceShape: String?
    
    /// 颧骨高低
    var cheekboneProminence: String?
    
    /// 下颌线类型
    var jawlineType: String?
    
    /// 下巴形状
    var chinShape: String?
    
    // MARK: - Eye Features
    
    /// 眼睛大小
    var eyeSize: String?
    
    /// 眼睛形状
    var eyeShape: String?
    
    /// 眼距
    var eyeDistance: String?
    
    /// 眉形
    var eyebrowShape: String?
    
    // MARK: - Nose Features
    
    /// 鼻子长度
    var noseLength: String?
    
    /// 鼻子宽度
    var noseWidth: String?
    
    // MARK: - Lips Features
    
    /// 嘴唇厚度
    var lipsThickness: String?
    
    /// 嘴唇形状
    var lipsShape: String?
    
    // MARK: - Skin Features
    
    /// 肤质
    var skinType: String?
    
    /// 肤色
    var skinTone: String?
    
    // MARK: - Demographics
    
    /// 年龄范围
    var ageRange: String?
    
    // MARK: - Initialization
    
    init() {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Methods
    
    /// 更新属性
    func updateAttributes(
        faceShape: FaceShape? = nil,
        cheekboneProminence: CheekboneProminence? = nil,
        jawlineType: JawlineType? = nil,
        chinShape: ChinShape? = nil,
        eyeSize: EyeSize? = nil,
        eyeShape: EyeShape? = nil,
        eyeDistance: EyeDistance? = nil,
        eyebrowShape: EyebrowShape? = nil,
        noseLength: NoseLength? = nil,
        noseWidth: NoseWidth? = nil,
        lipsThickness: LipsThickness? = nil,
        lipsShape: LipsShape? = nil,
        skinType: SkinType? = nil,
        skinTone: SkinTone? = nil,
        ageRange: AgeRange? = nil
    ) {
        if let faceShape = faceShape { self.faceShape = faceShape.rawValue }
        if let cheekboneProminence = cheekboneProminence { self.cheekboneProminence = cheekboneProminence.rawValue }
        if let jawlineType = jawlineType { self.jawlineType = jawlineType.rawValue }
        if let chinShape = chinShape { self.chinShape = chinShape.rawValue }
        if let eyeSize = eyeSize { self.eyeSize = eyeSize.rawValue }
        if let eyeShape = eyeShape { self.eyeShape = eyeShape.rawValue }
        if let eyeDistance = eyeDistance { self.eyeDistance = eyeDistance.rawValue }
        if let eyebrowShape = eyebrowShape { self.eyebrowShape = eyebrowShape.rawValue }
        if let noseLength = noseLength { self.noseLength = noseLength.rawValue }
        if let noseWidth = noseWidth { self.noseWidth = noseWidth.rawValue }
        if let lipsThickness = lipsThickness { self.lipsThickness = lipsThickness.rawValue }
        if let lipsShape = lipsShape { self.lipsShape = lipsShape.rawValue }
        if let skinType = skinType { self.skinType = skinType.rawValue }
        if let skinTone = skinTone { self.skinTone = skinTone.rawValue }
        if let ageRange = ageRange { self.ageRange = ageRange.rawValue }
        
        self.updatedAt = Date()
    }
    
    /// 获取所有已设置的属性标签
    func getAllTags() -> [String] {
        var tags: [String] = []
        
        if let faceShape = faceShape { tags.append(faceShape) }
        if let cheekboneProminence = cheekboneProminence { tags.append(cheekboneProminence) }
        if let jawlineType = jawlineType { tags.append(jawlineType) }
        if let chinShape = chinShape { tags.append(chinShape) }
        if let eyeSize = eyeSize { tags.append(eyeSize) }
        if let eyeShape = eyeShape { tags.append(eyeShape) }
        if let eyeDistance = eyeDistance { tags.append(eyeDistance) }
        if let eyebrowShape = eyebrowShape { tags.append(eyebrowShape) }
        if let noseLength = noseLength { tags.append(noseLength) }
        if let noseWidth = noseWidth { tags.append(noseWidth) }
        if let lipsThickness = lipsThickness { tags.append(lipsThickness) }
        if let lipsShape = lipsShape { tags.append(lipsShape) }
        if let skinType = skinType { tags.append(skinType) }
        if let skinTone = skinTone { tags.append(skinTone) }
        if let ageRange = ageRange { tags.append(ageRange) }
        
        return tags
    }
    
    /// 计算与教程视频的匹配度（0.0 - 1.0）
    func matchScore(with tutorialTags: [String]) -> Double {
        let userTags = Set(getAllTags())
        let videoTags = Set(tutorialTags)
        let matchingTags = userTags.intersection(videoTags)
        
        guard !userTags.isEmpty else { return 0.0 }
        
        return Double(matchingTags.count) / Double(userTags.count)
    }
}

// MARK: - Extensions

extension UserFaceAttributes {
    /// 类型安全的属性访问
    var faceShapeEnum: FaceShape? {
        get { faceShape.flatMap { FaceShape(rawValue: $0) } }
        set { faceShape = newValue?.rawValue }
    }
    
    var cheekboneProminenceEnum: CheekboneProminence? {
        get { cheekboneProminence.flatMap { CheekboneProminence(rawValue: $0) } }
        set { cheekboneProminence = newValue?.rawValue }
    }
    
    var jawlineTypeEnum: JawlineType? {
        get { jawlineType.flatMap { JawlineType(rawValue: $0) } }
        set { jawlineType = newValue?.rawValue }
    }
    
    var chinShapeEnum: ChinShape? {
        get { chinShape.flatMap { ChinShape(rawValue: $0) } }
        set { chinShape = newValue?.rawValue }
    }
    
    var eyeSizeEnum: EyeSize? {
        get { eyeSize.flatMap { EyeSize(rawValue: $0) } }
        set { eyeSize = newValue?.rawValue }
    }
    
    var eyeShapeEnum: EyeShape? {
        get { eyeShape.flatMap { EyeShape(rawValue: $0) } }
        set { eyeShape = newValue?.rawValue }
    }
    
    var eyeDistanceEnum: EyeDistance? {
        get { eyeDistance.flatMap { EyeDistance(rawValue: $0) } }
        set { eyeDistance = newValue?.rawValue }
    }
    
    var eyebrowShapeEnum: EyebrowShape? {
        get { eyebrowShape.flatMap { EyebrowShape(rawValue: $0) } }
        set { eyebrowShape = newValue?.rawValue }
    }
    
    var noseLengthEnum: NoseLength? {
        get { noseLength.flatMap { NoseLength(rawValue: $0) } }
        set { noseLength = newValue?.rawValue }
    }
    
    var noseWidthEnum: NoseWidth? {
        get { noseWidth.flatMap { NoseWidth(rawValue: $0) } }
        set { noseWidth = newValue?.rawValue }
    }
    
    var lipsThicknessEnum: LipsThickness? {
        get { lipsThickness.flatMap { LipsThickness(rawValue: $0) } }
        set { lipsThickness = newValue?.rawValue }
    }
    
    var lipsShapeEnum: LipsShape? {
        get { lipsShape.flatMap { LipsShape(rawValue: $0) } }
        set { lipsShape = newValue?.rawValue }
    }
    
    var skinTypeEnum: SkinType? {
        get { skinType.flatMap { SkinType(rawValue: $0) } }
        set { skinType = newValue?.rawValue }
    }
    
    var skinToneEnum: SkinTone? {
        get { skinTone.flatMap { SkinTone(rawValue: $0) } }
        set { skinTone = newValue?.rawValue }
    }
    
    var ageRangeEnum: AgeRange? {
        get { ageRange.flatMap { AgeRange(rawValue: $0) } }
        set { ageRange = newValue?.rawValue }
    }
}

