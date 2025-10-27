//
//  FaceDetectionFailedView.swift
//  HackWords
//
//  Created by Claude on 2025/10/25.
//

import SwiftUI
import GLUtils
import GLMP
import GLTrackingExtension

/// 人脸检测失败重试页面
struct FaceDetectionFailedView: View {
    let onTryAgain: () -> Void
    
    var body: some View {
        ZStack {
            // 背景图片
            Image("app_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // 图标
                Image("onboarding_retry")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 74, height: 74)
                    .padding(.bottom, 32)
                
                // 标题
                Text(GLMPLanguage.onboarding_face_detection_failed_title)
                    .font(.avenirMedium(24))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 1, green: 0.96, blue: 0.99))
                    .frame(width: 335, alignment: .top)
                    .padding(.bottom, 16)
                
                // 副标题
                Text(GLMPLanguage.onboarding_face_detection_failed_subtitle)
                    .font(.avenirLight(14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 1, green: 0.96, blue: 0.99).opacity(0.7))
                    .frame(width: 335, alignment: .top)
                
                Spacer()
                
                // Try Again 按钮
                Button(action: {
                    // Retry 点击埋点
                    GLMPTracking.tracking("onboarding_facescan_retry_click")
                    onTryAgain()
                }) {
                    Text(GLMPLanguage.onboarding_face_try_again)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
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
                .padding(.horizontal, 34)
                .padding(.bottom, 16)
                .safeAreaPadding(.bottom)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            // 页面曝光埋点
            GLMPTracking.tracking("onboarding_facescan_failed_exposure")
        }
    }
}

#Preview {
    FaceDetectionFailedView {
        debugPrint("Try Again tapped")
    }
}

