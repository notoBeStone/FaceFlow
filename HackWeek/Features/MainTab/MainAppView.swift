//
//  MainAppView.swift
//  HackWords
//
//  Created by Claude on 2025/10/13.
//

import SwiftUI
import GLMP

/// 主应用界面Props
struct MainAppViewProps {
    var onSettings: (() -> Void)?
}

/// 主应用界面
struct MainAppView: ComposablePageComponent {
    // MARK: - ComposablePageComponent Protocol
    typealias ComponentProps = MainAppViewProps

    let props: ComponentProps

    init(props: ComponentProps = MainAppViewProps()) {
        self.props = props
    }

    var pageName: String { "main_app" }

    var pageTrackingParams: [String: Any]? {
        [
            .TRACK_KEY_FROM: "main",
            .TRACK_KEY_TYPE: "home"
        ]
    }

    // MARK: - State Variables
    @State private var selectedTab = 0
    @State private var videoPlayerManager = VideoPlayerManager()
    @Namespace private var animationNamespace
    
    // MARK: - Environment
    @Environment(\.tracking) private var tracking

    var body: some View {
        ZStack {
            // Tab 内容层
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        Text(GLMPLanguage.tab_home)
                            .font(.avenirTabBarMedium)
                    }
                    .tag(0)
                
                ScanView()
                    .tabItem {
                        Image(systemName: selectedTab == 1 ? "camera.fill" : "camera")
                        Text(GLMPLanguage.tab_scan)
                            .font(.avenirTabBarMedium)
                    }
                    .tag(1)
                
                MeView()
                    .tabItem {
                        Image(systemName: selectedTab == 2 ? "person.fill" : "person")
                        Text(GLMPLanguage.tab_me)
                            .font(.avenirTabBarMedium)
                    }
                    .tag(2)
            }
            .accentColor(.mainColor)
            
            // 视频播放器覆盖层 - 添加动画
            if let video = videoPlayerManager.selectedVideo {
                SimpleVideoPlayerView(video: video, namespace: animationNamespace) {
                    videoPlayerManager.dismissPlayer()
                }
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .opacity
                ))
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: videoPlayerManager.selectedVideo != nil)
        .environment(\.videoPlayerManager, videoPlayerManager)
        .environment(\.animationNamespace, animationNamespace)
    }
}


#Preview {
    MainAppView()
}
