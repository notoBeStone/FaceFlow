//
//  UserFaceAttributes+Tags.swift
//  HackWords
//
//  Created by Claude on 2025/10/22.
//

import Foundation

// MARK: - Convert Face Attributes to Tutorial Tags

extension FaceShape {
    var tutorialTag: TutorialTag {
        switch self {
        case .round: return .round
        case .oval: return .oval
        case .square: return .square
        case .oblong: return .oblong
        case .heart: return .heart
        case .invertedTriangle: return .invertedTriangle
        }
    }
}

extension CheekboneProminence {
    var tutorialTag: TutorialTag {
        switch self {
        case .high: return .cheekboneHigh
        case .normal: return .cheekboneNormal
        case .low: return .cheekboneLow
        }
    }
}

extension JawlineType {
    var tutorialTag: TutorialTag {
        switch self {
        case .round: return .roundJawline
        case .sharp: return .sharpJawline
        case .square: return .squareJawline
        case .defined: return .definedJawline
        }
    }
}

extension ChinShape {
    var tutorialTag: TutorialTag {
        switch self {
        case .pointed: return .chinPointed
        case .round: return .roundChin
        case .wide: return .chinWide
        }
    }
}

extension EyeSize {
    var tutorialTag: TutorialTag {
        switch self {
        case .small: return .eyeSmall
        case .normal: return .normalEye
        case .large: return .eyeLarge
        }
    }
}

extension EyeShape {
    var tutorialTag: TutorialTag {
        switch self {
        case .monolid: return .monolid
        case .doubleLid: return .doubleLid
        case .innerDouble: return .innerDouble
        case .puffy: return .puffy
        }
    }
}

extension EyeDistance {
    var tutorialTag: TutorialTag {
        switch self {
        case .wide: return .wideEye
        case .normal: return .normalDistance
        case .narrow: return .eyeNarrow
        }
    }
}

extension EyebrowShape {
    var tutorialTag: TutorialTag {
        switch self {
        case .straight: return .eyebrowStraight
        case .curved: return .eyebrowCurved
        case .arched: return .eyebrowArched
        case .angular: return .eyebrowAngular
        }
    }
}

extension NoseLength {
    var tutorialTag: TutorialTag {
        switch self {
        case .short: return .noseShort
        case .normal: return .normalNose
        case .long: return .noseLong
        }
    }
}

extension NoseWidth {
    var tutorialTag: TutorialTag {
        switch self {
        case .narrow: return .narrowNose
        case .normal: return .normalWidth
        case .wide: return .wideNose
        }
    }
}

extension LipsThickness {
    var tutorialTag: TutorialTag {
        switch self {
        case .thin: return .lipsThin
        case .medium: return .lipsMedium
        case .thick: return .lipsThick
        }
    }
}

extension LipsShape {
    var tutorialTag: TutorialTag {
        switch self {
        case .topHeavy: return .lipsTopHeavy
        case .bottomHeavy: return .lipsBottomHeavy
        case .balanced: return .lipsBalanced
        }
    }
}

extension SkinType {
    var tutorialTag: TutorialTag {
        switch self {
        case .dry: return .skinDry
        case .oily: return .skinOily
        case .normal: return .normalSkin
        case .combination: return .skinCombination
        case .sensitive: return .skinSensitive
        }
    }
}

extension SkinTone {
    var tutorialTag: TutorialTag {
        switch self {
        case .light: return .skinToneLight
        case .medium: return .skinToneMedium
        case .golden: return .skinToneGolden
        case .dark: return .skinToneDark
        }
    }
}

extension SkinBlemishes {
    var tutorialTag: TutorialTag {
        switch self {
        case .noneOrFew: return .blemishesNone
        case .moderate: return .blemishesModerate
        case .many: return .blemishesMany
        }
    }
}

extension AgeRange {
    var tutorialTag: TutorialTag {
        switch self {
        case .under18: return .under18
        case .age19to25: return .age19to25
        case .age26to35: return .age26to35
        case .age36to45: return .age36to45
        case .over45: return .over45
        }
    }
}

// MARK: - UserFaceAttributes Helper

extension UserFaceAttributes {
    /// 获取所有用户属性对应的教程标签
    func getAllTutorialTags() -> [TutorialTag] {
        var tags: [TutorialTag] = []
        
        if let faceShape = faceShapeEnum {
            tags.append(faceShape.tutorialTag)
        }
        
        if let cheekbone = cheekboneProminenceEnum {
            tags.append(cheekbone.tutorialTag)
        }
        
        if let jawline = jawlineTypeEnum {
            tags.append(jawline.tutorialTag)
        }
        
        if let chin = chinShapeEnum {
            tags.append(chin.tutorialTag)
        }
        
        if let eyeSize = eyeSizeEnum {
            tags.append(eyeSize.tutorialTag)
        }
        
        if let eyeShape = eyeShapeEnum {
            tags.append(eyeShape.tutorialTag)
        }
        
        if let eyeDistance = eyeDistanceEnum {
            tags.append(eyeDistance.tutorialTag)
        }
        
        if let eyebrow = eyebrowShapeEnum {
            tags.append(eyebrow.tutorialTag)
        }
        
        if let noseLength = noseLengthEnum {
            tags.append(noseLength.tutorialTag)
        }
        
        if let noseWidth = noseWidthEnum {
            tags.append(noseWidth.tutorialTag)
        }
        
        if let lips = lipsThicknessEnum {
            tags.append(lips.tutorialTag)
        }
        
        if let lipsShape = lipsShapeEnum {
            tags.append(lipsShape.tutorialTag)
        }
        
        if let skinType = skinTypeEnum {
            tags.append(skinType.tutorialTag)
        }
        
        if let skinTone = skinToneEnum {
            tags.append(skinTone.tutorialTag)
        }
        
        if let blemishes = skinBlemishesEnum {
            tags.append(blemishes.tutorialTag)
        }
        
        if let ageRange = ageRangeEnum {
            tags.append(ageRange.tutorialTag)
        }
        
        return tags
    }
    
    /// 获取标签的字符串数组（用于视频匹配）
    func getAllTagStrings() -> [String] {
        return getAllTutorialTags().map { $0.rawValue }
    }
}

// MARK: - TutorialVideo Helper

extension TutorialVideo {
    /// 根据用户属性计算匹配度（0.0 - 1.0）
    func matchScore(for userAttributes: UserFaceAttributes) -> Double {
        let userTags = Set(userAttributes.getAllTagStrings())
        let videoTags = Set(self.tags)
        let matchedTags = userTags.intersection(videoTags)
        
        // 如果视频没有标签，返回 0
        guard !videoTags.isEmpty else { return 0.0 }
        
        // 计算匹配百分比
        return Double(matchedTags.count) / Double(videoTags.count)
    }
    
    /// 判断视频是否匹配用户属性
    func matches(userAttributes: UserFaceAttributes, threshold: Double = 0.3) -> Bool {
        return matchScore(for: userAttributes) >= threshold
    }
}

