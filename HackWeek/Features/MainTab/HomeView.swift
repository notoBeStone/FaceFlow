//
//  HomeView.swift
//  HackWords
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI
import GLMP

/// Home 页面
struct HomeView: View {
    // MARK: - Properties
    
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.videoPlayerManager) private var videoPlayerManager
    @Environment(\.animationNamespace) private var animationNamespace
    
    // 网格列配置：2列
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainBG
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Beginner 区域
                        makeSectionView(
                            title: GLMPLanguage.home_section_beginner,
                            videos: viewModel.beginnerVideos,
                            tag: .beginner,
                            hasMore: true
                        )
                        
                        // Advanced 区域
                        makeSectionView(
                            title: GLMPLanguage.home_section_advanced,
                            videos: viewModel.advancedVideos,
                            tag: .advanced,
                            hasMore: true
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle(GLMPLanguage.main_app_title)
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
    
    // MARK: - Helper Views
    
    /// 创建区域视图
    private func makeSectionView(title: String, videos: [TutorialVideo], tag: TutorialTag, hasMore: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // 区域标题
            Text(title)
                .font(.avenirTitle3Heavy)
                .foregroundColor(.g9L)
            
            // 2*2 网格
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(videos.prefix(4)) { video in
                    SimpleVideoCardView(
                        video: video,
                        namespace: animationNamespace,
                        isPlaying: videoPlayerManager.playingVideoId == video.id
                    )
                    .onTapGesture {
                        videoPlayerManager.showPlayer(for: video)
                    }
                }
            }
            
            // More 链接（右对齐）
            if hasMore {
                HStack {
                    Spacer()
                    NavigationLink(destination: VideoListView(tag: tag, videos: videos)) {
                        Text(GLMPLanguage.common_more_arrow)
                            .font(.avenirBodyMedium)
                            .foregroundColor(.g9L)
                    }
                }
            }
            
        }
    }
    
}

#Preview {
    HomeView()
}

