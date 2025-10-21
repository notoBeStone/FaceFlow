//
//  OnboardingManager.swift
//  HackWords
//
//  Created by Claude on 2025/10/13.
//

import Foundation

/// Onboarding 管理器 - 管理 Onboarding 完成状态
@MainActor
class OnboardingManager: ObservableObject {
    
    static let shared = OnboardingManager()
    
    private init() {
        loadOnboardingStatus()
    }
    
    // MARK: - UserDefaults Key
    
    private static let onboardingCompletedKey = "HackWords_OnboardingCompleted"
    
    // MARK: - Published Properties
    
    /// 是否已完成 Onboarding
    @Published var isOnboardingCompleted: Bool = false
    
    // MARK: - Public Methods
    
    /// 标记 Onboarding 为已完成
    func markOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: Self.onboardingCompletedKey)
        isOnboardingCompleted = true
        print("✅ Onboarding 已标记为完成")
    }
    
    /// 重置 Onboarding 状态（仅用于调试）
    func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: Self.onboardingCompletedKey)
        isOnboardingCompleted = false
        print("🔄 Onboarding 状态已重置")
    }
    
    // MARK: - Private Methods
    
    /// 加载 Onboarding 状态
    private func loadOnboardingStatus() {
        isOnboardingCompleted = UserDefaults.standard.bool(forKey: Self.onboardingCompletedKey)
    }
}
