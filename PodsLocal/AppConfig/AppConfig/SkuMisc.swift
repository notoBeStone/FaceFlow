//
//  SkuMisc.swift
//  AquaAI
//
//  Created by stephenwzl on 9/11/25.
//

import Foundation
import GLPurchaseExtension
import GLPurchaseUIExtension

struct AppSkuConfigModel {
    let skuId: String
    let period: SkuPeriod
    let trialDays: Int
    let category: SkuCategory
    let adjustToken: String?
    let skuLevel: SkuLevel
    
    
    /// 创建一个 sku
    /// - Parameters:
    ///   - skuId: appstore connect 填写的 skuId
    ///   - period: 周期
    ///   - trialDays: 试用天数， 默认是 0
    ///   - category: 分类
    ///   - adjustToken: 调整token
    ///   - skuLevel: 等级，默认是 gold
    init(skuId: String, period: SkuPeriod, trialDays: Int = 0, category: SkuCategory, adjustToken: String? = nil, skuLevel: SkuLevel = .gold) {
        self.skuId = skuId
        self.period = period
        self.trialDays = trialDays
        self.category = category
        self.adjustToken = adjustToken
        self.skuLevel = skuLevel
    }

    func toSkuModel() -> SkuSubscriptionModel {
        return SkuSubscriptionModel(sku: skuId, trailDays: trialDays, category: category, period: period, level: skuLevel, adjustToken: adjustToken, extra: nil)
    }
}
