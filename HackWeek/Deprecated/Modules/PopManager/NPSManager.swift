//
//  NPSManager.swift
//  KnitAI
//
//  Created by stephenwzl on 2025/1/15.
//

import GLPopupExtension
import GLCore
import GLMP
import Combine

enum KnitNPSEvent: String {
    case pdfExtract
    case chat
}
let KNIT_NPS_EVENT_KEY = "KNIT_NPS_EVENT_KEY"
let KNIT_NPS_SHOWED = "KNIT_NPS_SHOWED"

class NPSManager {
    private init() {}
    static let shared = NPSManager()
    
    func recordCompletedEvent(_ type: KnitNPSEvent) {
        let times = GLMPCache.get(key: KNIT_NPS_EVENT_KEY, default: 0)
        GLMPCache.set(key: KNIT_NPS_EVENT_KEY, value: times + 1)
    }
    
    /// 当结果页或者对话页面退出时调用
    @discardableResult
    func onChatPageExit() -> Bool {
        commonCheckToShow()
    }
    
    @discardableResult
    func onIdentifyComplete() -> Bool {
        commonCheckToShow()
    }
    
    @discardableResult 
    func onAquariumDetailBack() -> Bool {
        commonCheckToShow()
    }
    
    func commonCheckToShow() -> Bool {
        if GLMPCache.get(key: KNIT_NPS_SHOWED, default: false) {
            return false
        }
        GLMPCache.set(key: KNIT_NPS_SHOWED, value: true)
        PopManager.shared.showNPS {}
        return true
    }
}

enum KnitRateEvent: String {
    case pdfLike    // 记录 PDF结果点赞
    case chatLike // 记录消息点赞
    case chatMessageNum // 记录对话条数
}

enum KnitRateScene: String {
    case none
    case likeResult // 触发场景1
    case dailyMessages // 触发场景2
    case npsSatisfy  // 触发场景4
}

let CHAT_MSG_COUNT_DAILY = "CHAT_MSG_COUNT_DAILY"
class RateManager {
    private init() {}
    static let shared = RateManager()
    var resultLike: Bool = false
    var chatLike: Bool = false
    
    func recordEvent(_ type: KnitRateEvent) {
        switch type {
        case .pdfLike:
            resultLike = true
        case .chatLike:
            chatLike = true
        case .chatMessageNum:
            let num: ChatMessageCountCache = GLMPCache.get(key: CHAT_MSG_COUNT_DAILY) ?? ChatMessageCountCache(date: .now, count: 0)
            if num.date.isToday {
                GLMPCache.set(key: CHAT_MSG_COUNT_DAILY, value: ChatMessageCountCache(date: .now, count: num.count + 1))
            } else {
                GLMPCache.set(key: CHAT_MSG_COUNT_DAILY, value: ChatMessageCountCache(date: .now, count: 1))
            }
        }
    }
    
    func onEnterChatScene() {
        resultLike = false
        chatLike = false
    }
    
    @discardableResult
    @MainActor
    func onChatSceneExit() -> Bool {
        // 当日无弹窗
        guard PopManager.shared.hasPopToday == false else {
            return false
        }
        if resultLike || chatLike {
            PopManager.shared.showGoodReview(type: resultLike ? .resultFeedbackGood : .chatFeedbackGood)
            return true
        }
        let num: ChatMessageCountCache = GLMPCache.get(key: CHAT_MSG_COUNT_DAILY) ?? ChatMessageCountCache(date: .now, count: 0)
        if num.date.isToday && num.count >= 8 {
            PopManager.shared.showGoodReview(type: .multiChatMessages)
            return true
        }
        return false
    }
    
    @discardableResult
    @MainActor
    func homeSceneCheck() -> Bool {
        if PopManager.shared.hasGoodReviewToday == false, NPS.npsGood, GLMPAccount.isVip() {
            PopManager.shared.showGoodReview(type: .vipGoodNps)
            return true
        }
        return false
    }
}

struct ChatMessageCountCache: Codable {
    let date: Date
    let count: Int
}
