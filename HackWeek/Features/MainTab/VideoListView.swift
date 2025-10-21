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
    
    @Environment(\.videoPlayerManager) private var videoPlayerManager
    @Environment(\.animationNamespace) private var animationNamespace
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.mainBG
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(videos) { video in
                        SimpleVideoListCardView(
                            video: video,
                            namespace: animationNamespace,
                            isPlaying: videoPlayerManager.playingVideoId == video.id
                        )
                        .onTapGesture {
                            videoPlayerManager.showPlayer(for: video)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(tag.rawValue)
        .navigationBarTitleDisplayMode(.large)
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

