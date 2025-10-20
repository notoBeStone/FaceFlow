//
//  MaskCroppingUtil.swift
//  HackWords
//
//  Created by Claude on 2025/10/16.
//

import Foundation
import Vision
import CoreImage
import CoreVideo
import UIKit

/// 基于 mask 的智能图像裁剪工具类
/// 实现快速裁剪算法，根据 mask 的最小矩形透明区域进行裁剪
class MaskCroppingUtil {

    // MARK: - 配置参数

    /// 快速裁剪的块大小（32x32 像素块）
    private static let blockSize: Int = 32

    /// 最小有效区域阈值（避免过小的裁剪区域）
    private static let minimumCropSize: CGSize = CGSize(width: 50, height: 50)

    // MARK: - 主要接口

    /// 基于 mask observation 对图像进行智能裁剪
    /// - Parameters:
    ///   - maskObservation: VisionKit 生成的 mask observation
    ///   - originalImage: 原始图像
    ///   - croppedImage: 已经抠图后的图像
    /// - Returns: 裁剪优化后的图像，如果无法裁剪则返回原图
    static func cropImageBasedOnMask(
        maskObservation: VNInstanceMaskObservation,
        originalImage: UIImage,
        croppedImage: UIImage
    ) -> UIImage {

        let startTime = CFAbsoluteTimeGetCurrent()
        debugPrint("✂️ 开始基于 mask 的智能裁剪")

        do {
            // 1. 获取 mask 的像素数据
            let maskPixelBuffer = try maskObservation.generateMaskedImage(
                ofInstances: [0],
                from: VNImageRequestHandler(cgImage: originalImage.cgImage!, options: [:]),
                croppedToInstancesExtent: false
            )

            // 2. 分析 mask 数据计算最佳裁剪区域
            let cropRect = calculateOptimalCropRectFromMask(
                maskPixelBuffer: maskPixelBuffer,
                imageSize: originalImage.size
            )

            // 2. 验证裁剪区域的有效性
            guard isValidCropRect(cropRect, imageSize: croppedImage.size) else {
                debugPrint("⚠️ 裁剪区域无效，返回原图")
                return croppedImage
            }

            // 3. 执行图像裁剪
            let croppedResult = performImageCrop(croppedImage, cropRect: cropRect)

            let duration = CFAbsoluteTimeGetCurrent() - startTime
            debugPrint("✅ 智能裁剪完成，耗时: \(String(format: "%.3f", duration))s")
            debugPrint("📏 裁剪区域: \(cropRect)，原尺寸: \(croppedImage.size)，新尺寸: \(croppedResult.size)")

            return croppedResult

        } catch {
            debugPrint("❌ 智能裁剪失败: \(error.localizedDescription)")
            return croppedImage
        }
    }

    // MARK: - 核心算法实现

    /// 通过分析 mask 数据来计算最佳裁剪区域
    /// - Parameters:
    ///   - maskPixelBuffer: VisionKit 生成的 mask 像素缓冲区
    ///   - imageSize: 原始图像尺寸
    /// - Returns: 优化的裁剪矩形
    private static func calculateOptimalCropRectFromMask(
        maskPixelBuffer: CVPixelBuffer,
        imageSize: CGSize
    ) -> CGRect {

        let maskWidth = CVPixelBufferGetWidth(maskPixelBuffer)
        let maskHeight = CVPixelBufferGetHeight(maskPixelBuffer)

        debugPrint("📐 Mask 尺寸: \(maskWidth) x \(maskHeight)")
        debugPrint("🖼️ 图像尺寸: \(imageSize)")
        debugPrint("🔍 开始分析 mask 区域")

        // 将 mask 转换为灰度数组进行分析
        let maskData = extractMaskData(from: maskPixelBuffer)

        // 初始化边界值
        var minX = maskWidth
        var maxX = 0
        var minY = maskHeight
        var maxY = 0

        // 使用快速块状分析算法
        let blocksX = (maskWidth + blockSize - 1) / blockSize
        let blocksY = (maskHeight + blockSize - 1) / blockSize

        debugPrint("🔍 开始块状分析，块数量: \(blocksX) x \(blocksY)")

        // 块状分析：从左往右找 xmin，从右往左找 xmax，从上往下找 ymin，从下往上找 ymax
        for blockY in 0..<blocksY {
            for blockX in 0..<blocksX {
                // 计算当前块的像素范围
                let startX = blockX * blockSize
                let endX = min(startX + blockSize, maskWidth)
                let startY = blockY * blockSize
                let endY = min(startY + blockSize, maskHeight)

                // 检查块内是否有有效 mask 像素（主体区域）
                if hasValidMaskPixels(
                    maskData: maskData,
                    startX: startX, endX: endX,
                    startY: startY, endY: endY,
                    maskWidth: maskWidth
                ) {
                    // 更新边界
                    minX = min(minX, startX)
                    maxX = max(maxX, endX)
                    minY = min(minY, startY)
                    maxY = max(maxY, endY)
                }
            }
        }

        // 确保找到有效区域
        guard maxX > minX && maxY > minY else {
            debugPrint("⚠️ 未找到有效的 mask 区域")
            return CGRect(origin: .zero, size: imageSize)
        }

        // 添加小的边距以避免边缘截断
        let padding = 2
        minX = max(0, minX - padding)
        maxX = min(maskWidth, maxX + padding)
        minY = max(0, minY - padding)
        maxY = min(maskHeight, maxY + padding)

        // 转换为图像坐标
        let scaleX = imageSize.width / CGFloat(maskWidth)
        let scaleY = imageSize.height / CGFloat(maskHeight)

        let cropRect = CGRect(
            x: CGFloat(minX) * scaleX,
            y: CGFloat(minY) * scaleY,
            width: CGFloat(maxX - minX) * scaleX,
            height: CGFloat(maxY - minY) * scaleY
        )

        debugPrint("📊 计算得到的裁剪区域: \(cropRect)")

        return cropRect
    }

    
    /// 从像素缓冲区提取 mask 数据
    private static func extractMaskData(from pixelBuffer: CVPixelBuffer) -> [UInt8] {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

        var maskData = [UInt8](repeating: 0, count: width * height)

        // 提取 alpha 通道作为 mask 数据
        for y in 0..<height {
            let row = baseAddress!.advanced(by: y * bytesPerRow)
            let pixelData = row.assumingMemoryBound(to: UInt8.self)

            for x in 0..<width {
                // 假设 BGRA 格式，获取 alpha 通道
                let alphaOffset = x * 4 + 3
                maskData[y * width + x] = pixelData[alphaOffset]
            }
        }

        return maskData
    }

    /// 检查块内是否有有效的 mask 像素（主体区域）
    /// - Parameters:
    ///   - maskData: mask 数据数组
    ///   - startX, endX: 块的 x 范围
    ///   - startY, endY: 块的 y 范围
    ///   - maskWidth: mask 总宽度
    /// - Returns: 是否包含有效的 mask 像素
    private static func hasValidMaskPixels(
        maskData: [UInt8],
        startX: Int, endX: Int,
        startY: Int, endY: Int,
        maskWidth: Int
    ) -> Bool {

        // Mask 阈值，大于此值认为是有效区域（主体区域）
        // 在 VisionKit 的 mask 中，高值通常表示主体区域
        let threshold: UInt8 = 128

        for y in startY..<endY {
            let rowOffset = y * maskWidth
            for x in startX..<endX {
                let maskValue = maskData[rowOffset + x]
                if maskValue > threshold {
                    return true
                }
            }
        }

        return false
    }

    /// 验证裁剪区域的有效性
    private static func isValidCropRect(_ cropRect: CGRect, imageSize: CGSize) -> Bool {
        // 检查是否在图像范围内
        guard cropRect.origin.x >= 0,
              cropRect.origin.y >= 0,
              cropRect.maxX <= imageSize.width,
              cropRect.maxY <= imageSize.height else {
            debugPrint("⚠️ 裁剪区域超出图像范围")
            return false
        }

        // 检查最小尺寸要求
        guard cropRect.width >= minimumCropSize.width,
              cropRect.height >= minimumCropSize.height else {
            debugPrint("⚠️ 裁剪区域过小: \(cropRect.size)")
            return false
        }

        // 检查是否有效节省空间（至少减少 10% 的面积）
        let originalArea = imageSize.width * imageSize.height
        let cropArea = cropRect.width * cropRect.height
        let reductionRatio = 1.0 - (cropArea / originalArea)

        guard reductionRatio >= 0.1 else {
            debugPrint("⚠️ 裁剪区域节省空间过少: \(String(format: "%.1f", reductionRatio * 100))%")
            return false
        }

        debugPrint("✅ 裁剪区域有效，节省空间: \(String(format: "%.1f", reductionRatio * 100))%")
        return true
    }

    /// 执行图像裁剪操作
    private static func performImageCrop(_ image: UIImage, cropRect: CGRect) -> UIImage {
        guard let cgImage = image.cgImage else {
            debugPrint("❌ 无法获取 CGImage")
            return image
        }

        // 转换坐标系统（iOS 中 UIImage 和 CGImage 的 Y 轴方向相反）
        let adjustedCropRect = CGRect(
            x: cropRect.origin.x,
            y: image.size.height - cropRect.origin.y - cropRect.height,
            width: cropRect.width,
            height: cropRect.height
        )

        guard let croppedCGImage = cgImage.cropping(to: adjustedCropRect) else {
            debugPrint("❌ 裁剪操作失败")
            return image
        }

        let croppedImage = UIImage(cgImage: croppedCGImage)
        debugPrint("✅ 图像裁剪成功")

        return croppedImage
    }

    // MARK: - 性能监控

    /// 获取处理统计信息
    static func getPerformanceStats() -> [String: Any] {
        return [
            "blockSize": blockSize,
            "minimumCropSize": minimumCropSize,
            "algorithm": "Fast Block Analysis",
            "version": "1.0.0"
        ]
    }
}