//
//  SurveyFatigueManager.swift
//  HackWeek
//
//  Created by AI Assistant on 2025/10/16.
//

import Foundation
import GLTrackingExtension
import GLMP

/// 问卷疲劳度管理器
/// 负责管理取消订阅问卷的展示频率和历史记录，确保用户不被重复打扰
class SurveyFatigueManager {
    // MARK: - Singleton
    static let shared = SurveyFatigueManager()
    
    private init() {}
    
    // MARK: - Constants
    private enum Keys {
        static let shownTypes = "com.hackweek.survey.cancel.shown_types"
        static let lastShownDate = "com.hackweek.survey.cancel.last_shown_date"
        static let hasSubmitted = "com.hackweek.survey.cancel.has_submitted"
        static let dismissCount = "com.hackweek.survey.cancel.dismiss_count"
    }
    
    // MARK: - Storage Models
    private struct SurveyHistory: Codable {
        var shownTypes: [String]     // 已展示的问卷类型
        var lastShownDate: Date?     // 最后展示时间
        var hasSubmitted: Bool       // 是否已提交
        var dismissCount: Int        // 关闭次数
        
        init() {
            self.shownTypes = []
            self.lastShownDate = nil
            self.hasSubmitted = false
            self.dismissCount = 0
        }
    }
    
    // MARK: - Public Methods
    
    /// 检查是否应该展示问卷
    /// - Returns: true 表示应该展示，false 表示不应该展示
    func shouldShowSurvey() -> Bool {
        // 1. 检查是否满足业务条件
        let currentType = SurveyCancelType.currentType
        guard currentType != .unknown else {
            logDebug("问卷不展示: 未满足业务条件 (currentType = unknown)")
            return false
        }
        
        // 2. 加载历史记录
        let history = loadHistory()
        
        // 3. 检查是否已提交过
        if history.hasSubmitted {
            logDebug("问卷不展示: 用户已提交过问卷")
            return false
        }
        
        // 4. 检查是否已展示过相同类型
        if history.shownTypes.contains(currentType.rawValue) {
            logDebug("问卷不展示: 已展示过相同类型 (\(currentType.rawValue))")
            return false
        }
        
        // 5. 可以展示
        logDebug("问卷应该展示: type = \(currentType.rawValue)")
        return true
    }
    
    /// 记录问卷已展示
    /// - Parameter type: 问卷类型（可选，默认使用当前类型）
    func markSurveyShown(type: SurveyCancelType? = nil) {
        let surveyType = type ?? SurveyCancelType.currentType
        guard surveyType != .unknown else { return }
        
        var history = loadHistory()
        
        // 记录展示类型（去重）
        if !history.shownTypes.contains(surveyType.rawValue) {
            history.shownTypes.append(surveyType.rawValue)
        }
        
        // 记录展示时间
        history.lastShownDate = Date()
        
        // 保存
        saveHistory(history)
        
        // 埋点：问卷展示
        trackEvent("survey_cancel_show", params: [
            .TRACK_KEY_TYPE: surveyType.rawValue,
            .TRACK_KEY_FROM: "main_app"
        ])
        
        logDebug("已记录问卷展示: type = \(surveyType.rawValue)")
    }
    
    /// 记录用户提交问卷
    func markSurveySubmitted() {
        var history = loadHistory()
        history.hasSubmitted = true
        saveHistory(history)
        
        logDebug("已记录用户提交问卷")
    }
    
    /// 记录用户关闭问卷
    func markSurveyDismissed() {
        var history = loadHistory()
        history.dismissCount += 1
        saveHistory(history)
        
        // 埋点：问卷关闭
        trackEvent("survey_cancel_dismiss", params: [
            .TRACK_KEY_TYPE: SurveyCancelType.currentType.rawValue,
            .TRACK_KEY_CONTENT: "not_now"
        ])
        
        logDebug("已记录用户关闭问卷，关闭次数: \(history.dismissCount)")
    }
    
    /// 获取当前问卷类型
    func getCurrentSurveyType() -> SurveyCancelType {
        return SurveyCancelType.currentType
    }
    
    /// 重置状态（用于测试）
    func resetState() {
        UserDefaults.standard.removeObject(forKey: Keys.shownTypes)
        UserDefaults.standard.removeObject(forKey: Keys.lastShownDate)
        UserDefaults.standard.removeObject(forKey: Keys.hasSubmitted)
        UserDefaults.standard.removeObject(forKey: Keys.dismissCount)
        
        logDebug("已重置问卷状态")
    }
    
    /// 获取当前历史记录（用于调试）
    func getHistory() -> String {
        let history = loadHistory()
        return """
        问卷历史记录:
        - 已展示类型: \(history.shownTypes.joined(separator: ", "))
        - 最后展示时间: \(history.lastShownDate?.description ?? "无")
        - 已提交: \(history.hasSubmitted)
        - 关闭次数: \(history.dismissCount)
        """
    }
    
    // MARK: - Private Methods
    
    /// 加载历史记录
    private func loadHistory() -> SurveyHistory {
        let shownTypes = UserDefaults.standard.stringArray(forKey: Keys.shownTypes) ?? []
        let lastShownDate = UserDefaults.standard.object(forKey: Keys.lastShownDate) as? Date
        let hasSubmitted = UserDefaults.standard.bool(forKey: Keys.hasSubmitted)
        let dismissCount = UserDefaults.standard.integer(forKey: Keys.dismissCount)
        
        var history = SurveyHistory()
        history.shownTypes = shownTypes
        history.lastShownDate = lastShownDate
        history.hasSubmitted = hasSubmitted
        history.dismissCount = dismissCount
        
        return history
    }
    
    /// 保存历史记录
    private func saveHistory(_ history: SurveyHistory) {
        UserDefaults.standard.set(history.shownTypes, forKey: Keys.shownTypes)
        if let date = history.lastShownDate {
            UserDefaults.standard.set(date, forKey: Keys.lastShownDate)
        }
        UserDefaults.standard.set(history.hasSubmitted, forKey: Keys.hasSubmitted)
        UserDefaults.standard.set(history.dismissCount, forKey: Keys.dismissCount)
        UserDefaults.standard.synchronize()
    }
    
    /// 埋点追踪
    private func trackEvent(_ eventName: String, params: [String: Any]) {
        GLMPTracking.tracking(eventName, parameters: params)
    }
    
    /// 调试日志
    private func logDebug(_ message: String) {
        #if DEBUG
        print("🎯 [SurveyFatigueManager] \(message)")
        #endif
    }
}

