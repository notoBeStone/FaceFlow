//
//  OnboardingManager.swift
//  HackWords
//
//  Created by Claude on 2025/10/13.
//

import Foundation

/// Onboarding数据管理器
@MainActor
class OnboardingManager: ObservableObject {

    static let shared = OnboardingManager()

    private init() {}

    // MARK: - UserDefaults Keys
    private enum Keys {
        static let onboardingCompleted = "HackWords_OnboardingCompleted"
        static let userPreferences = "HackWords_UserPreferences"
        static let onboardingData = "HackWords_OnboardingData"
    }

    // MARK: - Published Properties
    @Published var currentOnboardingData: OnboardingData?
    @Published var isOnboardingCompleted: Bool = false

    // MARK: - Public Methods

    /// 检查是否需要显示Onboarding
    func shouldShowOnboarding() -> Bool {
        return !UserDefaults.standard.bool(forKey: Keys.onboardingCompleted)
    }

    /// 保存Onboarding数据
    func saveOnboardingData(_ data: OnboardingData) {
        currentOnboardingData = data

        // 保存到UserDefaults
        if let encodedData = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encodedData, forKey: Keys.onboardingData)
        }

        // 保存用户偏好设置
        let userPreferences: [String: Any] = [
            "selectedAgeGroup": data.ageGroup,
            "selectedLanguage": data.targetLanguage,
            "languageCode": OnboardingLanguage(rawValue: data.targetLanguage)?.languageCode ?? "",
            "completedAt": data.createdAt
        ]
        UserDefaults.standard.set(userPreferences, forKey: Keys.userPreferences)

        // 如果数据标记为已完成，则更新完成状态
        if data.isCompleted {
            UserDefaults.standard.set(true, forKey: Keys.onboardingCompleted)
            isOnboardingCompleted = true
        }
    }

    /// 加载Onboarding数据
    func loadOnboardingData() {
        // 检查是否已完成Onboarding
        isOnboardingCompleted = UserDefaults.standard.bool(forKey: Keys.onboardingCompleted)

        // 尝试加载完整的Onboarding数据
        if let data = UserDefaults.standard.data(forKey: Keys.onboardingData),
           let onboardingData = try? JSONDecoder().decode(OnboardingData.self, from: data) {
            currentOnboardingData = onboardingData
        }
    }

    /// 获取用户偏好设置
    func getUserPreferences() -> [String: Any]? {
        return UserDefaults.standard.dictionary(forKey: Keys.userPreferences)
    }

    /// 标记Onboarding为已完成
    func markOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: Keys.onboardingCompleted)
        isOnboardingCompleted = true

        // 如果已有数据但未标记为完成，更新数据
        if var existingData = currentOnboardingData, !existingData.isCompleted {
            let completedData = OnboardingData(
                ageGroup: existingData.ageGroup,
                targetLanguage: existingData.targetLanguage,
                isCompleted: true
            )
            saveOnboardingData(completedData)
        }
    }

    /// 重置Onboarding状态（仅用于调试）
    func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: Keys.onboardingCompleted)
        UserDefaults.standard.removeObject(forKey: Keys.userPreferences)
        UserDefaults.standard.removeObject(forKey: Keys.onboardingData)

        currentOnboardingData = nil
        isOnboardingCompleted = false
    }

    /// 更新用户年龄组
    func updateAgeGroup(_ ageGroup: OnboardingAgeGroup) {
        let targetLanguage = currentOnboardingData?.targetLanguage ?? OnboardingLanguage.spanish.rawValue
        let newData = OnboardingData(
            ageGroup: ageGroup.rawValue,
            targetLanguage: targetLanguage,
            isCompleted: false
        )
        saveOnboardingData(newData)
    }

    /// 更新目标语言
    func updateTargetLanguage(_ language: OnboardingLanguage) {
        let ageGroup = currentOnboardingData?.ageGroup ?? OnboardingAgeGroup.age18to25.rawValue
        let newData = OnboardingData(
            ageGroup: ageGroup,
            targetLanguage: language.rawValue,
            isCompleted: false
        )
        saveOnboardingData(newData)
    }

    /// 显示Onboarding流程（如果需要）
    func showIfNeeded(completion: (() -> Void)? = nil) {
        loadOnboardingData()

        if shouldShowOnboarding() {
            showOnboarding(completion: completion)
        } else {
            completion?()
        }
    }

    /// 显示Onboarding流程（已废弃，现在由OnboardingRootView处理）
    @available(*, deprecated, message: "Use OnboardingRootView instead")
    func showOnboarding(completion: (() -> Void)? = nil) {
        // 这个方法已被废弃，Onboarding流程现在由OnboardingRootView处理
        completion?()
    }
}