//
//  SimpleVideoCardView.swift
//  HackWords
//
//  Created by Claude on 2025/10/21.
//

import SwiftUI

/// 简单的视频卡片视图（带动画）
struct SimpleVideoCardView: View {
    let video: TutorialVideo
    let namespace: Namespace.ID?
    let isPlaying: Bool
    
    init(video: TutorialVideo, namespace: Namespace.ID? = nil, isPlaying: Bool = false) {
        self.video = video
        self.namespace = namespace
        self.isPlaying = isPlaying
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 图片区域
            thumbnailView
                .frame(maxWidth: .infinity)
                .aspectRatio(16.0 / 9.0, contentMode: .fit)
            
            // 标题
            Text(video.title)
                .font(.avenirBodyMedium)
                .foregroundColor(.g9L)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private var thumbnailView: some View {
        if let namespace = namespace {
            VideoThumbnailView(
                thumbnailURL: video.thumbnailURL,
                duration: video.formattedDuration
            )
            .matchedGeometryEffect(id: "videoPlayer_\(video.id)", in: namespace)
        } else {
            VideoThumbnailView(
                thumbnailURL: video.thumbnailURL,
                duration: video.formattedDuration
            )
        }
    }
}

/// 简单的视频列表卡片视图（横向布局，带动画）
struct SimpleVideoListCardView: View {
    let video: TutorialVideo
    let namespace: Namespace.ID?
    let isPlaying: Bool
    
    init(video: TutorialVideo, namespace: Namespace.ID? = nil, isPlaying: Bool = false) {
        self.video = video
        self.namespace = namespace
        self.isPlaying = isPlaying
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 左侧：缩略图
            thumbnailView
            
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
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private var thumbnailView: some View {
        if let namespace = namespace {
            VideoThumbnailView(
                thumbnailURL: video.thumbnailURL,
                duration: video.formattedDuration,
                width: 120,
                height: 100,
                playIconSize: 32
            )
            .matchedGeometryEffect(id: "videoPlayer_\(video.id)", in: namespace)
        } else {
            VideoThumbnailView(
                thumbnailURL: video.thumbnailURL,
                duration: video.formattedDuration,
                width: 120,
                height: 100,
                playIconSize: 32
            )
        }
    }
}

