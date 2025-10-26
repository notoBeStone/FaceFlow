//
//  FaceAnalysisResult.swift
//  HackWords
//
//  Created by Claude on 2025/10/26.
//

import Foundation

/// 面部分析 API 返回结果
struct FaceAnalysisResult: Codable {
    let faceShape: String
    let cheekboneProminence: String
    let jawlineType: String
    let chinShape: String
    let eyeSize: String
    let eyeShape: String
    let eyeDistance: String
    let eyebrowShape: String
    let noseLength: String
    let noseWidth: String
    let lipsThickness: String
    let lipsShape: String
    let skinTone: String
    let skinBlemishes: String
}

extension FaceAnalysisResult {
    /// 验证所有字段是否有效
    func isValid() -> Bool {
        // 验证每个字段是否符合预期的枚举值
        return FaceShape(rawValue: faceShape) != nil &&
               CheekboneProminence(rawValue: cheekboneProminence) != nil &&
               JawlineType(rawValue: jawlineType) != nil &&
               ChinShape(rawValue: chinShape) != nil &&
               EyeSize(rawValue: eyeSize) != nil &&
               EyeShape(rawValue: eyeShape) != nil &&
               EyeDistance(rawValue: eyeDistance) != nil &&
               EyebrowShape(rawValue: eyebrowShape) != nil &&
               NoseLength(rawValue: noseLength) != nil &&
               NoseWidth(rawValue: noseWidth) != nil &&
               LipsThickness(rawValue: lipsThickness) != nil &&
               LipsShape(rawValue: lipsShape) != nil &&
               SkinTone(rawValue: skinTone) != nil &&
               SkinBlemishes(rawValue: skinBlemishes) != nil
    }
}

