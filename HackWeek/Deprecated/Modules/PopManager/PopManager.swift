//
//  PopManager.swift
//  AINote
//
//  Created by Martin on 2024/11/26.
//

import Foundation
import GLMP
import GLPopupExtension
import GLCore

enum GoodReviewType: Codable {
    // 好评
    case resultFeedbackGood
    // 聊天好评
    case chatFeedbackGood
    // 单日对话条数 >= 8
    case multiChatMessages
    // nps满意
    case vipGoodNps
    
    case onboarding
}

enum SeekGoodReviewMode: Int, Codable {
    case score = 0  // 系统求好评
    case custom // 自定义求好评弹框
}

struct GoodReviewData: Codable {
    let type: GoodReviewType
    let mode: SeekGoodReviewMode
    let time: Double
}

class PopManager {
    private var goodReviewDataCache = GLMPModelCacheManager<[GoodReviewData]>(key: "goodReviewPopCache")
    var goodReviewDatas: [GoodReviewData] {
        get {
            self.goodReviewDataCache.datas ?? []
        }
        
        set {
            self.goodReviewDataCache.setData(newValue)
        }
    }
    
    private var npsShowTimeCacheKey = "npsShowTimeCacheKey"
    private var npsShowTime: Double? {
        get {
            if !GLMPCache.contains(key: npsShowTimeCacheKey) {
                return nil
            }
            return GLMPCache.get(key: npsShowTimeCacheKey)
        }
        
        set {
            GLMPCache.set(key: npsShowTimeCacheKey, value: newValue)
        }
    }
    
    static let shared = PopManager()
    
    private init() {}
    
    func appendGoodReview(_ type: GoodReviewType, mode: SeekGoodReviewMode) {
        var datas = self.goodReviewDatas
        datas.insert(.init(type: type, mode: mode, time: Date().timeIntervalSince1970), at: 0)
        self.goodReviewDatas = datas
    }
    
    var hasGoodReviewToday: Bool {
        self.goodReviewDatas.contains{$0.time.isToday}
    }
    
    var hasPopToday: Bool {
        if let npsShowTime, npsShowTime.isToday {
            return true
        }
        return hasGoodReviewToday
    }
    
    // MARK:  - NPS
    var hasShowNps: Bool {
        self.npsShowTime != nil
    }
    
    func npsShow() {
        self.npsShowTime = Date().timeIntervalSince1970
    }
}

struct NPS {
    static var score: Int? {
        guard let result = GL().Popup_NPSSubmittedResult() else {
            return nil
        }
        return result.score
    }
    
    static var npsGood: Bool {
        if let score, score >= 8 {
            return true
        }
        return false
    }
}

extension PopManager {
    func showNPS(completion: @escaping ()->()) {
        self.npsShow()
        GL().Popup_Show(.nps, completion: completion)
    }
    
    @MainActor
    func showGoodReview(type: GoodReviewType) {
        SeekGoodReview.show(source: type)
    }
}
