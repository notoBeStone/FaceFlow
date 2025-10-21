//
//  VideoCardView.swift
//  HackWords
//
//  Created by Claude on 2025/10/21.
//

import SwiftUI

/// 视频卡片视图（支持全屏动画）
struct VideoCardView: View {
    // MARK: - Properties
    
    let video: TutorialVideo
    let namespace: Namespace.ID
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 图片区域
            VideoThumbnailView(
                thumbnailURL: video.thumbnailURL,
                duration: video.formattedDuration
            )
            .matchedGeometryEffect(id: "video_\(video.id)", in: namespace)
            .aspectRatio(1.2, contentMode: .fit)
            
            // 标题
            Text(video.title)
                .font(.avenirBodyMedium)
                .foregroundColor(.g9L)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

/// 视频列表卡片视图（横向布局）
struct VideoListCardView: View {
    // MARK: - Properties
    
    let video: TutorialVideo
    let namespace: Namespace.ID
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 左侧：缩略图
            VideoThumbnailView(
                thumbnailURL: video.thumbnailURL,
                duration: video.formattedDuration,
                width: 120,
                height: 100,
                playIconSize: 32
            )
            .matchedGeometryEffect(id: "video_\(video.id)", in: namespace)
            
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

