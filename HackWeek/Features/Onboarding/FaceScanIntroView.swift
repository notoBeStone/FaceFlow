//
//  FaceScanIntroView.swift
//  HackWords
//
//  Created by Claude on 2025/10/25.
//

import SwiftUI
import GLUtils
import GLMP
import GLTrackingExtension

/// 面部扫描介绍页面
struct FaceScanIntroView: View {
    let onContinue: (UIImage) -> Void  // 传递检测到的人脸图片
    let onSkip: () -> Void
    
    @State private var showPhotoSourceSheet = false
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var shouldOpenPicker = false
    @State private var selectedSourceType: PhotoSourceType?
    @State private var selectedImage: UIImage?
    @State private var isDetecting = false
    @State private var showRetryView = false
    
    var body: some View {
        ZStack {
            // 背景图片
            Image("app_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .frame(height: GLScreenHeight)

            
            VStack(spacing: 0) {
                Spacer()
                
                // 中间内容区域(垂直居中)
                VStack(spacing: 10) {
                    // 面部扫描图标
                    Image("onboarding_face")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 74, height: 74)
                    
                    // 标题
                    Text(GLMPLanguage.onboarding_face_scan_title)
                        .font(.avenirMedium(24))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 1, green: 0.96, blue: 0.99))
                        .frame(width: 335)
                        .padding(.top, 8)
                    
                    // 副标题
                    Text(GLMPLanguage.onboarding_face_scan_subtitle)
                        .font(.avenirLight(14))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 1, green: 0.96, blue: 0.99).opacity(0.7))
                        .frame(width: 335)
                }
                
                Spacer()
                
                // 底部按钮区域
                VStack(spacing: 4) {
                    // Continue 按钮
                    Button(action: {
                        // Continue 点击埋点
                        GLMPTracking.tracking("onboarding_facescan_continue_click")
                        showPhotoSourceSheet = true
                    }) {
                        Text(GLMPLanguage.text_continue)
                            .font(.avenirMedium(16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1, green: 0.302, blue: 0.557),      // #FF4D8E
                                        Color(red: 0.655, green: 0.098, blue: 0.824)   // #A719D2
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 20)
                    
                    // Skip 按钮
                    Button(action: {
                        // Skip 点击埋点
                        GLMPTracking.tracking("onboarding_facescan_skip_click")
                        onSkip()
                    }) {
                        Text(GLMPLanguage.onboarding_carousel_skip)
                            .font(.avenirMedium(16))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.63, green: 0.63, blue: 0.63))
                            .padding(.vertical, 12)
                    }
                }
                .padding(.bottom, 16)
            }
            .ignoresSafeArea(edges: .bottom)
            
            // 人脸检测加载指示器
            if isDetecting {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text(GLMPLanguage.onboarding_face_detecting)
                            .font(.avenirMedium(16))
                            .foregroundColor(.white)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.8))
                    )
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 0)
        }
        .onAppear {
            // 页面曝光埋点
            GLMPTracking.tracking("onboarding_facescan_exposure")
        }
        .fullScreenCover(isPresented: $showPhotoSourceSheet, onDismiss: {
            // 弹窗关闭后，根据选择打开对应的相机或相册
            if shouldOpenPicker {
                shouldOpenPicker = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if let sourceType = selectedSourceType {
                        if sourceType == .camera {
                            showCamera = true
                        } else {
                            showPhotoLibrary = true
                        }
                    }
                }
            }
        }) {
            PhotoSourceSheet { sourceType in
                // 照片来源选择埋点
                GLMPTracking.tracking("onboarding_facescan_source_click", parameters: [
                    GLT_PARAM_TYPE: sourceType == .camera ? "camera" : "photo_library"
                ])
                selectedSourceType = sourceType
                shouldOpenPicker = true
            }
            .background(ClearBackgroundView())
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                handleImageSelection(image)
            }
        }
        .sheet(isPresented: $showPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary) { image in
                handleImageSelection(image)
            }
        }
        .fullScreenCover(isPresented: $showRetryView) {
            FaceDetectionFailedView {
                // 重新尝试
                showRetryView = false
                showPhotoSourceSheet = true
            }
        }
    }
    
    // MARK: - 处理图片选择
    
    private func handleImageSelection(_ image: UIImage) {
        selectedImage = image
        isDetecting = true
        
        Task {
            let result = await FaceDetectionHelper.detectQualityFace(in: image)
            
            await MainActor.run {
                isDetecting = false
                
                if result.isQualified {
                    // 人脸检测成功埋点（调试用）
                    GLMPTracking.tracking("onboarding_facescan_detect_success_debug")
                    // 人脸检测通过，保存图片并继续流程
                    saveFaceImage(image)
                    onContinue(image)
                } else {
                    // 人脸检测失败埋点（调试用）
                    GLMPTracking.tracking("onboarding_facescan_detect_failed_debug")
                    // 检测失败，显示 Retry 页面
                    showRetryView = true
                }
            }
        }
    }
    
    // MARK: - 保存人脸图片
    
    private func saveFaceImage(_ image: UIImage) {
        // TODO: 实现图片保存逻辑
        // 可以保存到 UserDefaults、本地文件或数据库
        debugPrint("✅ 保存人脸图片")
    }
}

// MARK: - Clear Background View

/// 透明背景视图（用于 fullScreenCover）
struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - Preview

#if DEBUG
#Preview {
    FaceScanIntroView { image in
        debugPrint("Continue tapped with image")
    } onSkip: {
        debugPrint("Skip tapped")
    }
}
#endif

