//
//  CameraModeSheet.swift
//  HackWeek
//
//  Created by Claude on 2025/10/22.
//

import SwiftUI
import GLMP

/// 相机模式选择弹窗
struct CameraModeSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onModeSelected: (ScanType) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 妆容分析选项
                ModeOptionView(
                    icon: "face.smiling",
                    title: GLMPLanguage.scan_mode_makeup,
                    description: GLMPLanguage.scan_mode_makeup_desc,
                    color: .mainColor
                ) {
                    onModeSelected(.makeup)
                    dismiss()
                }
                
                Divider()
                    .padding(.horizontal, 20)
                
                // 产品扫描选项
                ModeOptionView(
                    icon: "cube.box",
                    title: GLMPLanguage.scan_mode_product,
                    description: GLMPLanguage.scan_mode_product_desc,
                    color: .mainSecondary
                ) {
                    onModeSelected(.product)
                    dismiss()
                }
                
                Spacer()
            }
            .background(Color.mainBG)
            .navigationTitle(GLMPLanguage.scan_mode_select_title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(GLMPLanguage.text_cancel) {
                        dismiss()
                    }
                    .foregroundColor(.g9L)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

/// 模式选项视图
private struct ModeOptionView: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 图标
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(color)
                }
                
                // 文字
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.avenirTitle3Heavy)
                        .foregroundColor(.g9L)
                    
                    Text(description)
                        .font(.avenirBodyRoman)
                        .foregroundColor(.g6L)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // 箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.g5L)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CameraModeSheet { _ in }
}

