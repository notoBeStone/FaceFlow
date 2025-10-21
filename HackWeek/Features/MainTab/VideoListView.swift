//
//  VideoListView.swift
//  HackWords
//
//  Created by Claude on 2025/10/21.
//

import SwiftUI
import GLMP

/// 视频列表页面
struct VideoListView: View {
    // MARK: - Properties
    
    let tag: TutorialTag
    let videos: [TutorialVideo]
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.g0L
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(videos) { video in
                        makeContentCard(video: video)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(tag.rawValue)
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Helper Views
    
    /// 创建内容卡片（横向布局）
    private func makeContentCard(video: TutorialVideo) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // 左侧：缩略图
            VideoThumbnailView(
                thumbnailURL: video.thumbnailURL,
                duration: video.formattedDuration,
                width: 120,
                height: 100,
                playIconSize: 32
            )
            
            // 右侧：标题和摘要
            VStack(alignment: .leading, spacing: 6) {
                Text(video.title)
                    .font(.avenirBodyMedium)
                    .foregroundColor(.g9L)
                    .lineLimit(2)
                
                if let summary = video.summary {
                    Text(summary)
                        .font(.avenirBody2Roman)
                        .foregroundColor(.g6L)
                        .lineLimit(2)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 100)
    }
}

#Preview {
    NavigationStack {
        VideoListView(
            tag: .beginner,
            videos: [
                TutorialVideo(
                    title: "Everyday Makeup Tutorial",
                    summary: "Learn the basics of everyday makeup in just 10 minutes",
                    thumbnailURL: "https://picsum.photos/seed/makeup1/400/300",
                    videoUrl: "https://example.com/video1.mp4",
                    duration: 600
                )
            ]
        )
    }
}

