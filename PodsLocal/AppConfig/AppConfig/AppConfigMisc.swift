//
//  AppConfigMisc.swift
//  AquaAI
//
//  Created by stephenwzl on 9/11/25.
//

import Foundation

struct AppEvoConfig {
    /// sku 配置
    static var skuConfig: [AppSkuConfigModel] {
        [
            // 19.99年包
            .init(skuId: "AquaAI_sub_year", period: .yearly, trialDays: 0, category: .none, adjustToken: nil, skuLevel: .gold),
            
            // 3.99周包 3天试用
            .init(skuId: "AquaAI_sub_week_3dt", period: .weekly, trialDays: 3, category: .freeTrail, adjustToken: nil, skuLevel: .gold),
            
            // 3.99周包 无试用
            .init(skuId: "AquaAI_sub_week", period: .weekly, trialDays: 0, category: .none, adjustToken: nil, skuLevel: .gold),
            
            // 3.99周包，首周 0.99
            .init(skuId: "AquaAI_sub_week_099", period: .weekly, trialDays: 0, category: .none, adjustToken: nil, skuLevel: .gold),
            
            // 39.99 年包，3天试用，skuId 起错了
            .init(skuId: "okayfish_sub_year_7dt", period: .yearly, trialDays: 3, category: .freeTrail, adjustToken: nil, skuLevel: .gold),
            
            // 39.99 年包，首月优惠 1.99
            .init(skuId: "okayfish_sub_year_30dt_1.99", period: .yearly, trialDays: 0, category: .none, adjustToken: nil, skuLevel: .gold),
            
            // 39.99 年包，无试用
            .init(skuId: "okayfish_sub_year", period: .yearly, trialDays: 0, category: .none, adjustToken: nil, skuLevel: .gold),
        ]
    }
}
