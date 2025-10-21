//
//  VipHeaderVideoPlayer.swift
//  AquaAI
//
//  Created on 2025/10/21.
//

import SwiftUI
import AVFoundation
import AVKit

struct VipHeaderVideoPlayer: View {
    let videoName: String
    let aspectRatio: CGFloat
    @StateObject private var playerManager = VipHeaderVideoManager()
    
    var body: some View {
        ZStack {
            // 白色背景，防止视频加载时出现黑底
            Color.white
            
            GeometryReader { geometry in
                if let player = playerManager.player {
                    VideoPlayer(player: player)
                        .aspectRatio(aspectRatio, contentMode: .fit)
                        .disabled(true) // 禁用播放器控制
                        .background(Color.white) // 视频背景也设为白色
                        .onAppear {
                            playerManager.play()
                        }
                        .onDisappear {
                            playerManager.pause()
                        }
                } else {
                    // 加载失败时显示白色占位符
                    Rectangle()
                        .fill(Color.white)
                        .aspectRatio(aspectRatio, contentMode: .fit)
                }
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .onAppear {
            playerManager.setupPlayer(videoName: videoName)
        }
    }
}

class VipHeaderVideoManager: ObservableObject {
    @Published var player: AVPlayer?
    private var playerObserver: NSObjectProtocol?
    
    func setupPlayer(videoName: String) {
        guard let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            print("❌ 无法找到视频文件: \(videoName).mp4")
            return
        }
        
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        player?.isMuted = true // 静音播放
        
        // 监听播放结束事件
        playerObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            // 播放结束后停止，不循环
            self?.player?.pause()
        }
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    deinit {
        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

