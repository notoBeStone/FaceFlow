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
    
    // MARK: - Environment
    @Environment(\.tracking) private var tracking

    var body: some View {
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
        
    }
}


#Preview {
    MainAppView()
}
