//
//  CameraViewModel.swift
//  HackWords
//
//  Created by Claude on 2025/10/13.
//

import Foundation
import SwiftUI
import AVFoundation

@MainActor
class CameraViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var showingPermissionAlert = false

    // 检查相机权限
    func checkCameraPermission() {
        // 权限检查现在在 CameraViewController 中处理
        // 这个方法保留用于 alert 状态管理
    }

    // 处理拍摄完成的图片
    func processCapturedImage(_ image: UIImage) {
        capturedImage = image

        // 跳转到识别页
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            TemplateAPI.Navigator.push(IdentificationPage(image: image), from: "camera")
        })
    }

    // 处理用户取消拍照
    func handleCancel() {
        // 关闭当前页面
        TemplateAPI.Navigator.dismiss()
    }

    // 重置状态
    func reset() {
        capturedImage = nil
    }
}
