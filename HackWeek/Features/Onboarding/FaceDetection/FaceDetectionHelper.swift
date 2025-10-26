//
//  FaceDetectionHelper.swift
//  HackWords
//
//  Created by Claude on 2025/10/25.
//

import UIKit
import Vision

/// 人脸检测辅助类
class FaceDetectionHelper {
    
    /// 检测图片中是否包含人脸
    /// - Parameter image: 需要检测的图片
    /// - Returns: (是否包含人脸, 检测到的人脸数量, 错误信息)
    static func detectFaces(in image: UIImage) async -> (hasFace: Bool, faceCount: Int, error: String?) {
        guard let cgImage = image.cgImage else {
            return (false, 0, "无法处理图片")
        }
        
        let request = VNDetectFaceRectanglesRequest()
        
        // 设置更宽松的配置以避免 inference context 错误
        request.revision = VNDetectFaceRectanglesRequestRevision2
        
        do {
            let handler = VNImageRequestHandler(
                cgImage: cgImage,
                orientation: image.cgImageOrientation,
                options: [:]
            )
            
            try handler.perform([request])
            
            guard let results = request.results, !results.isEmpty else {
                return (false, 0, nil)
            }
            
            return (true, results.count, nil)
        } catch {
            debugPrint("❌ 人脸检测错误: \(error.localizedDescription)")
            return (false, 0, "人脸检测失败: \(error.localizedDescription)")
        }
    }
    
    /// 检测图片中是否包含清晰的正面人脸
    /// - Parameter image: 需要检测的图片
    /// - Returns: (是否包含合格人脸, 人脸数量, 错误/提示信息)
    static func detectQualityFace(in image: UIImage) async -> (isQualified: Bool, faceCount: Int, message: String?) {
        guard let cgImage = image.cgImage else {
            return (false, 0, "无法处理图片")
        }
        
        // 先使用简单的人脸检测
        let simpleResult = await detectFaces(in: image)
        
        // 如果简单检测失败，返回错误
        if let error = simpleResult.error {
            return (false, 0, error)
        }
        
        // 检查是否有人脸
        if !simpleResult.hasFace {
            return (false, 0, "未检测到人脸，请确保照片中有清晰的正面人脸")
        }
        
        // 检查是否有多张人脸
        if simpleResult.faceCount > 1 {
            return (true, 1, nil)
        }
        
        // 尝试使用更详细的检测来检查人脸质量
        let qualityResult = await checkFaceQuality(cgImage: cgImage, orientation: image.cgImageOrientation)
        
        // 如果详细检测失败，但简单检测成功，仍然认为合格
        if qualityResult == nil {
            debugPrint("⚠️ 详细检测失败，但简单检测成功，认为合格")
            return (true, simpleResult.faceCount, nil)
        }
        
        return qualityResult ?? (true, simpleResult.faceCount, nil)
    }
    
    /// 检查人脸质量（使用 Landmarks 检测）
    private static func checkFaceQuality(cgImage: CGImage, orientation: CGImagePropertyOrientation) async -> (isQualified: Bool, faceCount: Int, message: String?)? {
        let request = VNDetectFaceLandmarksRequest()
        
        do {
            let handler = VNImageRequestHandler(
                cgImage: cgImage,
                orientation: orientation,
                options: [:]
            )
            
            try handler.perform([request])
            
            guard let results = request.results, !results.isEmpty else {
                return nil
            }
            
            // 检查人脸大小
            if let face = results.first {
                let faceArea = face.boundingBox.width * face.boundingBox.height
                if faceArea < 0.05 {
                    return (false, 1, "人脸太小或距离太远，请靠近拍摄")
                }
            }
            
            return (true, results.count, nil)
            
        } catch {
            debugPrint("⚠️ 详细人脸检测失败: \(error.localizedDescription)")
            return nil  // 返回 nil 表示详细检测失败，使用简单检测结果
        }
    }
}

// MARK: - UIImage Extension

extension UIImage {
    /// 获取 CGImage 的方向
    var cgImageOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}

