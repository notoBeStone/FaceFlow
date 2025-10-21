//
//  MeView.swift
//  HackWords
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI
import GLMP

/// Me 页面
struct MeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainBG
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 个人资料头部
                        VStack(spacing: 12) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.mainColor, .mainSecondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                )
                            
                            Text(GLMPLanguage.me_title)
                                .font(.avenirTitle2Heavy)
                                .foregroundColor(.g9L)
                            
                            Text(GLMPLanguage.me_description)
                                .font(.avenirBodyRoman)
                                .foregroundColor(.g6L)
                        }
                        .padding(.top, 40)
                        
                        // 设置列表
                        VStack(spacing: 0) {
                            ForEach(0..<5) { index in
                                makeSettingRow(index: index)
                                
                                if index < 4 {
                                    Divider()
                                        .padding(.leading, 20)
                                }
                            }
                        }
                        .background(Color.gwL)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(GLMPLanguage.tab_me)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Helper Views
    
    private func makeSettingRow(index: Int) -> some View {
        HStack(spacing: 16) {
            Image(systemName: getSettingIcon(index: index))
                .font(.system(size: 20))
                .foregroundColor(.mainColor)
                .frame(width: 24)
            
            Text(getSettingTitle(index: index))
                .font(.avenirBodyRoman)
                .foregroundColor(.g9L)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.g5L)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }
    
    // MARK: - Helper Methods
    
    private func getSettingIcon(index: Int) -> String {
        switch index {
        case 0: return "person.circle.fill"
        case 1: return "heart.circle.fill"
        case 2: return "bell.circle.fill"
        case 3: return "gear.circle.fill"
        case 4: return "questionmark.circle.fill"
        default: return "circle.fill"
        }
    }
    
    private func getSettingTitle(index: Int) -> String {
        switch index {
        case 0: return "Account Settings"
        case 1: return "My Favorites"
        case 2: return "Notifications"
        case 3: return "App Settings"
        case 4: return "Help & Support"
        default: return "Setting"
        }
    }
}

#Preview {
    MeView()
}

