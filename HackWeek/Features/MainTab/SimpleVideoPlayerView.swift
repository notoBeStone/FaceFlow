//
//  SimpleVideoPlayerView.swift
//  HackWords
//
//  Created by Claude on 2025/10/21.
//

import SwiftUI
import AVKit
import GLUtils
import GLMP
import Kingfisher

/// 简单的视频播放页面（带动画）
struct SimpleVideoPlayerView: View {
    // MARK: - Properties
    
    let video: TutorialVideo
    let namespace: Namespace.ID
    let onDismiss: () -> Void
    
    @StateObject private var playerViewModel: SimpleVideoPlayerViewModel
    
    // MARK: - Initialization
    
    init(video: TutorialVideo, namespace: Namespace.ID, onDismiss: @escaping () -> Void) {
        self.video = video
        self.namespace = namespace
        self.onDismiss = onDismiss
        self._playerViewModel = StateObject(wrappedValue: SimpleVideoPlayerViewModel(videoURL: video.videoUrl))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                                
                // 视频播放器区域
                ZStack {
                    // 视频播放器层 - 使用系统原生 VideoPlayer
                    Group {
                        if let player = playerViewModel.player {
                            VideoPlayer(player: player)
                        } else {
                            // 加载中或错误状态
                            Color.black
                        }
                    }
                    .matchedGeometryEffect(id: "videoPlayer_\(video.id)", in: namespace)
                    
                    // 封面图和加载动效覆盖层 - 独立的一层
                    if !playerViewModel.isVideoReady {
                        thumbnailLoadingOverlay
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(16/9, contentMode: .fit)
                .animation(.easeOut(duration: 0.3), value: playerViewModel.isVideoReady)
                
                // 视频信息区域
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 标题
                        Text(video.title)
                            .font(.avenirTitle3Heavy)
                            .foregroundColor(.white)
                        
                        // 标签
                        if !video.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(video.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.avenirBody2Roman)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.mainColor.opacity(0.3))
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        
                        // 描述
                        if let summary = video.summary {
                            Text(summary)
                                .font(.avenirBodyRegular)
                                .foregroundColor(.white.opacity(0.8))
                                .lineSpacing(4)
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                }
                .background(Color.black)
            }
            .padding(.top, GLSafeNavigationHeight)
            
            // 关闭按钮 - 添加淡入动画
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        playerViewModel.pause()
                        onDismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.8))
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.3))
                                    .frame(width: 36, height: 36)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                Spacer()
            }
            .padding(.top, GLSafeStatusBarHeight)
            .transition(.opacity)
        }
        .onAppear {
            playerViewModel.play()
        }
        .onDisappear {
            playerViewModel.cleanup()
        }
    }
    
    // MARK: - Helper Views
    
    /// 封面图和加载动效覆盖层
    private var thumbnailLoadingOverlay: some View {
        GeometryReader { geometry in
            ZStack {
                // 封面图 - 使用 Kingfisher 强力缓存
                KFImage(URL(string: video.thumbnailURL))
                    .placeholder {
                        Color.black
                    }
                    .onFailure { _ in
                        // 加载失败时显示黑色背景
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                // 半透明遮罩
                Color.black.opacity(0.4)
                
                // Loading 动效
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    
                    Text(GLMPLanguage.common_loading)
                        .font(.avenirBodyRegular)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - SimpleVideoPlayerViewModel

/// 简单视频播放器 ViewModel
class SimpleVideoPlayerViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isVideoReady: Bool = false
    
    private var statusObserver: NSKeyValueObservation?
    
    init(videoURL: String) {
        setupPlayer(with: videoURL)
    }
    
    private func setupPlayer(with urlString: String) {
        guard let url = URL(string: urlString) else {
            print("❌ 无效的视频 URL: \(urlString)")
            return
        }
        
        print("✅ 开始加载视频: \(url)")
        
        // 创建播放器
        let player = AVPlayer(url: url)
        
        // 配置音频会话（重要！）
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ 音频会话配置失败: \(error)")
        }
        
        self.player = player
        
        // 监听视频加载状态
        statusObserver = player.currentItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                if item.status == .readyToPlay {
                    print("✅ 视频准备就绪")
                    self?.isVideoReady = true
                } else if item.status == .failed {
                    print("❌ 视频加载失败: \(item.error?.localizedDescription ?? "未知错误")")
                }
            }
        }
    }
    
    func play() {
        player?.play()
        print("▶️ 开始播放")
    }
    
    func pause() {
        player?.pause()
        print("⏸️ 暂停播放")
    }
    
    func cleanup() {
        statusObserver?.invalidate()
        statusObserver = nil
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        isVideoReady = false
        print("🧹 清理播放器")
    }
    
    deinit {
        cleanup()
    }
}

// MARK: - Preview

#Preview {
    @Namespace var namespace
    return SimpleVideoPlayerView(
        video: TutorialVideo(
            title: "Everyday Makeup Tutorial",
            summary: "Learn the basics of everyday makeup in just 10 minutes. This comprehensive tutorial covers foundation application, eye shadow techniques, and finishing touches.",
            thumbnailURL: "https://picsum.photos/seed/makeup1/400/300",
            videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            duration: 600,
            tags: ["Beginner", "Everyday", "Step by Step"]
        ),
        namespace: namespace,
        onDismiss: {}
    )
}

