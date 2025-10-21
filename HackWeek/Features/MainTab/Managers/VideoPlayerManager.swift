//
//  VideoPlayerManager.swift
//  HackWords
//
//  Created by Claude on 2025/10/21.
//

import SwiftUI

/// 视频播放器管理器 - 管理全局视频播放状态
@Observable
class VideoPlayerManager {
    /// 当前选中的视频
    var selectedVideo: TutorialVideo?
    
    /// 当前播放视频的 ID（用于 matchedGeometryEffect）
    var playingVideoId: String?
    
    /// 显示视频播放器
    func showPlayer(for video: TutorialVideo) {
        selectedVideo = video
        playingVideoId = video.id
    }
    
    /// 关闭视频播放器
    func dismissPlayer() {
        selectedVideo = nil
        // 延迟清除 ID，等待动画完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.playingVideoId = nil
        }
    }
}

/// VideoPlayerManager 的 Environment Key
struct VideoPlayerManagerKey: EnvironmentKey {
    static let defaultValue = VideoPlayerManager()
}

extension EnvironmentValues {
    var videoPlayerManager: VideoPlayerManager {
        get { self[VideoPlayerManagerKey.self] }
        set { self[VideoPlayerManagerKey.self] = newValue }
    }
}

/// AnimationNamespace 的 Environment Key
struct AnimationNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

extension EnvironmentValues {
    var animationNamespace: Namespace.ID? {
        get { self[AnimationNamespaceKey.self] }
        set { self[AnimationNamespaceKey.self] = newValue }
    }
}

