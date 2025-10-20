//
//  EdgeSmoothingUtil.swift
//  HackWords
//
//  Created by Claude on 2025/10/16.
//

import Foundation
import CoreImage
import UIKit

/// 图像边缘平滑处理工具类
/// 实现轻度抗锯齿算法，提升抠图后图像的视觉效果
class EdgeSmoothingUtil {

    // MARK: - 配置参数

    /// 平滑强度（轻度平滑）
    private static let smoothingRadius: Float = 0.5

    // MARK: - 主要接口

    /// 对抠图后的图像进行边缘平滑处理
    /// - Parameter image: 抠图后的图像（带透明通道）
    /// - Returns: 边缘平滑处理后的图像
    static func applyEdgeSmoothing(to image: UIImage) -> UIImage {
        guard image.hasAlphaChannel() else {
            debugPrint("⚠️ 图像没有 alpha 通道，跳过边缘平滑处理")
            return image
        }

        let startTime = CFAbsoluteTimeGetCurrent()
        debugPrint("🎨 开始边缘平滑处理")

        // 使用简化的平滑处理
        let smoothedImage = applySimpleSmoothing(to: image)

        let duration = CFAbsoluteTimeGetCurrent() - startTime
        debugPrint("✅ 边缘平滑处理完成，耗时: \(String(format: "%.3f", duration))s")

        return smoothedImage
    }

    // MARK: - 核心算法实现

    /// 简化版本的平滑处理
    static func applySimpleSmoothing(to image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else {
            return image
        }

        // 应用轻微的高斯模糊
        let context = CIContext(options: [.useSoftwareRenderer: false])
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(smoothingRadius, forKey: kCIInputRadiusKey)

        guard let filter = filter,
              let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }

        let result = UIImage(cgImage: cgImage)
        return result
    }

    // MARK: - 性能优化

    /// 检查图像是否需要边缘平滑处理
    static func shouldApplySmoothing(to image: UIImage) -> Bool {
        // 1. 检查图像尺寸（避免处理过大的图像）
        let imageSize = image.size
        let maxDimension = max(imageSize.width, imageSize.height)

        guard maxDimension <= 2000 else {
            debugPrint("⚠️ 图像尺寸过大 (\(maxDimension))，跳过边缘平滑处理")
            return false
        }

        // 2. 检查是否有透明通道
        guard image.hasAlphaChannel() else {
            debugPrint("⚠️ 图像没有透明通道，跳过边缘平滑处理")
            return false
        }

        return true
    }

    // MARK: - 性能监控

    /// 获取处理统计信息
    static func getPerformanceStats() -> [String: Any] {
        return [
            "smoothingRadius": smoothingRadius,
            "algorithm": "Simple Gaussian Blur",
            "version": "1.0.0"
        ]
    }
}

// MARK: - UIImage Extension

extension UIImage {
    /// 检查图像是否有 alpha 通道
    func hasAlphaChannel() -> Bool {
        guard let cgImage = self.cgImage else { return false }
        let alphaInfo = cgImage.alphaInfo
        return alphaInfo == .first || alphaInfo == .last ||
               alphaInfo == .premultipliedFirst || alphaInfo == .premultipliedLast
    }
}