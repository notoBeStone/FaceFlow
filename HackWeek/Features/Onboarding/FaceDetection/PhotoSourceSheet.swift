//
//  PhotoSourceSheet.swift
//  HackWords
//
//  Created by Claude on 2025/10/25.
//

import SwiftUI
import GLUtils

/// 照片来源选择类型
enum PhotoSourceType {
    case camera
    case gallery
}

/// 照片来源选择弹窗（自定义样式）
struct PhotoSourceSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSourceSelected: (PhotoSourceType) -> Void
    
    @State private var isPresented = false
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(isPresented ? 0.5 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissSheet()
                }
            
            VStack {
                Spacer()
                
                // 主内容卡片（从底部弹出）
                VStack(spacing: 0) {
                    // 标题栏
                    HStack {
                        Spacer()
                        
                        Text(GLMPLanguage.onboarding_face_scan_how)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // 关闭按钮
                        Button(action: {
                            dismissSheet()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(width: 32, height: 32)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    
                    // 拍照选项
                    PhotoSourceOptionButton(
                        icon: "camera.fill",
                        title: GLMPLanguage.onboarding_face_take_photo
                    ) {
                        onSourceSelected(.camera)
                        dismissSheet()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    // 相册选项
                    PhotoSourceOptionButton(
                        icon: "photo.on.rectangle.angled",
                        title: GLMPLanguage.onboarding_face_upload_gallery
                    ) {
                        onSourceSelected(.gallery)
                        dismissSheet()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(hex: 0x181920))
                )
                .offset(y: isPresented ? 0 : 500)
            }
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isPresented = true
            }
        }
    }
    
    private func dismissSheet() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
            isPresented = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
}

/// 照片来源选项按钮
private struct PhotoSourceOptionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 图标
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                
                // 文字
                Text(title)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white)
                
                Spacer()
                
                // 箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.06))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.bottom, 12)
    }
}

#Preview {
    PhotoSourceSheet { _ in }
}


