//
//  SeekGoodReview.swift
//  IOSProject
//
//  Created by Martin on 2024/3/5.
//

import Foundation
import GLConfig
import AppModels
import StoreKit
import GLCore
import GLTrackingExtension

class SeekGoodReview {
    @MainActor
    static func show(source: GoodReviewType) {
        if self.canSystemSeekGoodReview || source == .onboarding {
            self.systemSeekGoodReview(source)
        } else {
            PopManager.shared.appendGoodReview(source, mode: .custom)
            self.customSeekGoodReview(source)
        }
    }
    
    @MainActor
    private static func systemSeekGoodReview(_ source: GoodReviewType) {
        if Dice.gambler(50) && source != .onboarding {
            PopManager.shared.appendGoodReview(source, mode: .custom)
            self.customSeekGoodReview(source)
        } else {
            GL().Tracking_Event("goodreview_system_exposure", parameters: [GLT_PARAM_TYPE: source.event])
            PopManager.shared.appendGoodReview(source, mode: .score)
            let windowScene = UIApplication.shared.connectedScenes.first {
                guard let windowScene = $0 as? UIWindowScene else {
                    return false
                }
                return windowScene.screen.bounds.maxSide == UIScreen.main.bounds.maxSide
            } as? UIWindowScene
            if let windowScene = windowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
    
    private static func customSeekGoodReview(_ source: GoodReviewType) {
        GL().Tracking_Event("goodreview_custom_exposure", parameters: [GLT_PARAM_TYPE: source.event])
        let popView = SeekGoodReviewPopView(source: source) { should in
            if should {
                self.writeReview()
            }
        }
        popView.showInView(nil, animated: true) {}
    }
    
    private static func writeReview() {
        let urlString = GLConfig.appStoreReviewLink
        if let ulr = URL(string: urlString) {
            UIApplication.gl_open(url: ulr)
        }
    }
    
    private static var canSystemSeekGoodReview: Bool {
        PopManager.shared.goodReviewDatas.filter {$0.mode == .score}.count < 3
    }
}

extension CGRect {
    var maxSide: Double {
        return Swift.max(self.size.width, self.size.height)
    }
}

extension GoodReviewType {
    var event: String {
        switch self {
        case .resultFeedbackGood:
            return "resultFeedbackGood"
        case .multiChatMessages:
            return "multipleChatMessages"
        case .vipGoodNps:
            return "vipGoodNps"
        case .chatFeedbackGood:
            return "chatFeedbackGood"
        case .onboarding:
            return "onboarding"
        }
    }
}
