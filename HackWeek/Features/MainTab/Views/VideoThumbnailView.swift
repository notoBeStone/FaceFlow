//
//  VideoThumbnailView.swift
//  HackWords
//
//  Created by Claude on 2025/10/21.
//

import SwiftUI

/// 视频缩略图视图组件
struct VideoThumbnailView: View {
    // MARK: - Properties
    
    let thumbnailURL: String
    let duration: String?
    let width: CGFloat?
    let height: CGFloat?
    let cornerRadius: CGFloat
    let playIconSize: CGFloat
    
    // MARK: - Initialization
    
    init(
        thumbnailURL: String,
        duration: String? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        cornerRadius: CGFloat = 8,
        playIconSize: CGFloat = 40
    ) {
        self.thumbnailURL = thumbnailURL
        self.duration = duration
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.playIconSize = playIconSize
    }
    
    // MARK: - Body
    
    var body: some View {
        AsyncImage(url: URL(string: thumbnailURL)) { phase in
            switch phase {
            case .empty:
                // 加载中
                placeholderView
                    .overlay(
                        ProgressView()
                            .tint(.mainColor)
                    )
            case .success(let image):
                // 图片加载成功
                successView(image: image)
            case .failure:
                // 加载失败，显示占位符
                placeholderView
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: playIconSize))
                            .foregroundColor(.mainColor.opacity(0.5))
                    )
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: width, height: height)
    }
    
    // MARK: - Helper Views
    
    /// 占位符视图
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [.mainColor.opacity(0.15), .mainSecondary.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
    
    /// 成功加载的图片视图
    private func successView(image: Image) -> some View {
        Group {
            if let width = width, let height = height {
                // 固定尺寸模式
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .overlay(overlayContent)
            } else {
                // 自适应尺寸模式
                GeometryReader { geometry in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                }
                .overlay(overlayContent)
            }
        }
    }
    
    /// 叠加内容（播放按钮和时长）
    private var overlayContent: some View {
        ZStack {
            // 半透明遮罩
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.black.opacity(0.2))
            
            // 播放按钮
            Image(systemName: "play.circle.fill")
                .font(.system(size: playIconSize))
                .foregroundColor(.white.opacity(0.9))
            
            // 显示视频时长
            if let duration = duration {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(duration)
                            .font(.avenirBody2Roman)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(4)
                            .padding(6)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("固定尺寸") {
    VideoThumbnailView(
        thumbnailURL: "https://picsum.photos/seed/makeup1/400/300",
        duration: "10:30",
        width: 120,
        height: 100
    )
    .padding()
}

#Preview("自适应尺寸") {
    VideoThumbnailView(
        thumbnailURL: "https://picsum.photos/seed/makeup1/400/300",
        duration: "10:30"
    )
    .aspectRatio(1.2, contentMode: .fit)
    .padding()
}

