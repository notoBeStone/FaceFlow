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
            // 3.99周包 3天试用
            .init(skuId: "faceflow_sub_week_3dt", period: .weekly, trialDays: 3, category: .freeTrail, adjustToken: nil, skuLevel: .gold),
            
            // 3.99周包，首周 0.99
            .init(skuId: "faceflow_sub_week_7dt_099", period: .weekly, trialDays: 0, category: .none, adjustToken: nil, skuLevel: .gold),
        ]
    }
}
