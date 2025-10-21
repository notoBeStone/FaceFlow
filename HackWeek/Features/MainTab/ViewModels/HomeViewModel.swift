//
//  HomeViewModel.swift
//  HackWords
//
//  Created by Claude on 2025/10/20.
//

import Foundation
import SwiftUI

/// 首页 ViewModel
class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var beginnerVideos: [TutorialVideo] = []
    @Published var advancedVideos: [TutorialVideo] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Initialization
    
    init() {
        loadMockData()
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
    
    // MARK: - Private Methods
    
    /// 加载 Mock 数据
    private func loadMockData() {
        // Beginner 视频数据
        beginnerVideos = [
            TutorialVideo(
                title: "Everyday Makeup Tutorial",
                summary: "Learn the basics of everyday makeup in just 10 minutes",
                thumbnailURL: "https://picsum.photos/seed/makeup1/400/300",
                videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                duration: 600, // 10分钟
                tags: [
                    TutorialTag.beginner.rawValue,
                    TutorialTag.everyday.rawValue,
                    TutorialTag.stepByStep.rawValue
                ]
            ),
            TutorialVideo(
                title: "Natural Look Guide",
                summary: "Create a fresh, natural look perfect for any occasion",
                thumbnailURL: "https://picsum.photos/seed/makeup2/400/300",
                videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
                duration: 480, // 8分钟
                tags: [
                    TutorialTag.beginner.rawValue,
                    TutorialTag.naturalLook.rawValue,
                    TutorialTag.quickTips.rawValue
                ]
            ),
            TutorialVideo(
                title: "Simple Eye Makeup",
                summary: "Master basic eye makeup techniques for beginners",
                thumbnailURL: "https://picsum.photos/seed/makeup3/400/300",
                videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
                duration: 420, // 7分钟
                tags: [
                    TutorialTag.beginner.rawValue,
                    TutorialTag.eyeMakeup.rawValue
                ]
            ),
            TutorialVideo(
                title: "Quick Makeup Tips",
                summary: "Time-saving tips for a polished look in minutes",
                thumbnailURL: "https://picsum.photos/seed/makeup4/400/300",
                videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
                duration: 300, // 5分钟
                tags: [
                    TutorialTag.beginner.rawValue,
                    TutorialTag.quickTips.rawValue
                ]
            )
        ]
        
        // Advanced 视频数据
        advancedVideos = [
            TutorialVideo(
                title: "Glamorous Evening Makeup",
                summary: "Create a stunning evening look with professional techniques",
                thumbnailURL: "https://picsum.photos/seed/makeup5/400/300",
                videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
                duration: 900, // 15分钟
                tags: [
                    TutorialTag.advanced.rawValue,
                    TutorialTag.glamorous.rawValue,
                    TutorialTag.professional.rawValue
                ]
            ),
            TutorialVideo(
                title: "Smoky Eye Tutorial",
                summary: "Master the art of creating perfect smoky eyes",
                thumbnailURL: "https://picsum.photos/seed/makeup6/400/300",
                videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
                duration: 720, // 12分钟
                tags: [
                    TutorialTag.advanced.rawValue,
                    TutorialTag.smokyEye.rawValue,
                    TutorialTag.eyeMakeup.rawValue
                ]
            ),
            TutorialVideo(
                title: "Contouring Techniques",
                summary: "Advanced face sculpting and contouring methods",
                thumbnailURL: "https://picsum.photos/seed/makeup7/400/300",
                videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
                duration: 840, // 14分钟
                tags: [
                    TutorialTag.advanced.rawValue,
                    TutorialTag.contouring.rawValue,
                    TutorialTag.professional.rawValue
                ]
            ),
            TutorialVideo(
                title: "Highlighting Guide",
                summary: "Achieve the perfect glow with advanced highlighting",
                thumbnailURL: "https://picsum.photos/seed/makeup8/400/300",
                videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
                duration: 660, // 11分钟
                tags: [
                    TutorialTag.advanced.rawValue,
                    TutorialTag.highlighting.rawValue
                ]
            )
        ]
    }
}

