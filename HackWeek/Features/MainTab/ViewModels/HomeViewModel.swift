//
//  HomeViewModel.swift
//  HackWords
//
//  Created by Claude on 2025/10/20.
//

import Foundation
import SwiftUI
import SwiftData

/// 首页 ViewModel
class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var beginnerVideos: [TutorialVideo] = []
    @Published var advancedVideos: [TutorialVideo] = []
    @Published var recommendedVideos: [TutorialVideo] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private var allVideos: [TutorialVideo] = []
    private let modelContext: ModelContext?
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        loadVideosFromJSON()
        updateRecommendedVideos()
    }
    
    // MARK: - Public Methods
    
    /// 获取指定标签的视频列表
    func getVideos(withTag tag: TutorialTag) -> [TutorialVideo] {
        switch tag {
        case .beginner:
            return beginnerVideos
        case .advanced:
            return advancedVideos
        default:
            return []
        }
    }
    
    /// 更新推荐视频列表
    func updateRecommendedVideos() {
        guard let modelContext = modelContext else {
            // 如果没有 modelContext，返回空列表
            recommendedVideos = []
            return
        }
        
        // 获取用户面部属性
        let descriptor = FetchDescriptor<UserFaceAttributes>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        
        guard let userAttributes = try? modelContext.fetch(descriptor).first else {
            // 如果没有用户属性，返回空列表
            recommendedVideos = []
            return
        }
        
        // 获取用户的属性标签（排除难度标签）
        let userTags = Set(userAttributes.getAllTags())
        
        // 筛选匹配的视频
        let matchedVideos = allVideos.filter { video in
            // 获取视频的属性标签（排除难度标签）
            let videoAttributeTags = Set(video.tags.filter { tag in
                !isDifficultyTag(tag)
            })
            
            // 如果视频没有属性标签，则不推荐
            guard !videoAttributeTags.isEmpty else { return false }
            
            // 检查是否有交集（只要有一个匹配就展示）
            return !userTags.intersection(videoAttributeTags).isEmpty
        }
        
        // 按匹配度排序
        recommendedVideos = matchedVideos.sorted { video1, video2 in
            let score1 = calculateMatchScore(video: video1, userTags: userTags)
            let score2 = calculateMatchScore(video: video2, userTags: userTags)
            return score1 > score2
        }
    }
    
    // MARK: - Private Methods
    
    /// 从 JSON 文件加载视频数据
    private func loadVideosFromJSON() {
        guard let url = Bundle.main.url(forResource: "tutorial_videos", withExtension: "json") else {
            errorMessage = "无法找到视频数据文件"
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let videos = try JSONDecoder().decode([TutorialVideo].self, from: data)
            
            // 保存所有视频
            allVideos = videos
            
            // 根据标签分类视频（避免重复）
            // 规则：
            // 1. 有 Beginner 标签 → 放入 beginnerVideos
            // 2. 没有 Beginner 标签 → 放入 advancedVideos（无论有没有 Advanced 标签）
            beginnerVideos = videos.filter { $0.isBeginner }
            advancedVideos = videos.filter { !$0.isBeginner }
            
        } catch {
            errorMessage = "加载视频数据失败: \(error.localizedDescription)"
            print("❌ Failed to load tutorial videos: \(error)")
        }
    }
    
    /// 判断是否为难度标签（不参与匹配）
    private func isDifficultyTag(_ tag: String) -> Bool {
        return tag == TutorialTag.beginner.rawValue || tag == TutorialTag.advanced.rawValue
    }
    
    /// 计算视频与用户标签的匹配分数
    private func calculateMatchScore(video: TutorialVideo, userTags: Set<String>) -> Double {
        // 获取视频的属性标签（排除难度标签）
        let videoAttributeTags = Set(video.tags.filter { !isDifficultyTag($0) })
        
        guard !videoAttributeTags.isEmpty else { return 0.0 }
        
        // 计算匹配的标签数量
        let matchingTags = userTags.intersection(videoAttributeTags)
        
        // 匹配分数 = 匹配的标签数 / 用户标签总数
        // 这样可以优先推荐匹配更多用户属性的视频
        guard !userTags.isEmpty else { return 0.0 }
        
        return Double(matchingTags.count) / Double(userTags.count)
    }
}

