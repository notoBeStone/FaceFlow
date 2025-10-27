//
//  SKUConfig.swift
//  AINote
//
//  Created by xie.longyan on 2024/6/17.
//

import Foundation
import GLPurchaseExtension
import GLPurchaseUIExtension

public class SKUConfig {
    
    public static func subscriptionSkuList() -> [String] {
        
        let list = subscriptionSkuModelMap().compactMap { (key: String, value: SkuBaseModel) in
            if let model = value.toSubscriptionModel {
                return model.sku
            }
            return nil
        }
        
        return Array(Set(list))
    }
    
    public static func subscriptionTrialSkuList() -> [String] {
        let list = subscriptionSkuModelMap().compactMap { (key: String, value: SkuBaseModel) in
            if let model = value.toSubscriptionModel, model.isTrail {
                return model.sku
            }
            return nil
        }
        
        return Array(Set(list))
    }
    
    public static func subscriptionFamilySkuList() -> [String] {
        let list = subscriptionFamilySkuModelMap().compactMap { (key: String, value: SkuBaseModel) in
            if let model = value.toSubscriptionModel {
                return model.sku
            }
            return nil
        }
        
        return Array(Set(list))
    }
}

public enum SkuType: String, CaseIterable {

    // 3.99周包 3天试用
    case week3 = "faceflow_sub_week_3dt"
    // 3.99周包，首周 0.99
    case week099 = "faceflow_sub_week_7dt_099"
    
    var sku: String {
        self.rawValue
    }
    
    var key: String {
        self.rawValue
    }
    
    var trailDays: Int {
        switch self {
            case .week3:
                return 3
            default:
                return 0
        }
    }
    
    var category: SkuCategory {
        if self.trailDays == 0 {
            return .none
        }
        return .freeTrail
    }
    
    var period: SkuPeriod {
        switch self {
            case .week3, .week099:
                return .weekly
        }
    }
    
    var adjustToken: String? {
        return nil
    }
    
    var level: SkuLevel {
        return .gold
    }
    
    var skuModel: SkuSubscriptionModel {
        SkuSubscriptionModel(sku: self.sku,
                             trailDays: self.trailDays,
                             category: self.category,
                             period: self.period,
                             level: self.level,
                             adjustToken: self.adjustToken,
                             extra: nil)
    }
}

extension SKUConfig {
    
    public static var purchaseSkus: [String: SkuBaseModel] {
        return buildSkuMap()
    }
    
    /// 获取试用订阅的SKU列表
    public static var purchaseTrialSkus: [String] {
        var skus: [String] = []
        purchaseSkus.forEach { key, model in
            if model.category == .freeTrail {
                skus.append(model.sku)
            }
        }
        return skus
    }
    
    /// 获取家庭共享订阅的SKU列表
    public static var familySharedSkus: [String] {
        let skus: [String] = subscriptionFamilySkuModelMap().compactMap { $1.sku }
        return skus
    }
    
    
    private static func buildSkuMap() -> [String: SkuBaseModel] {
        var skuMap: [String: SkuBaseModel] = [:]
        
        // 订阅包 + 一次性消费包
        
        skuMap.merge(subscriptionSkuModelMap()) { (_, new) in new }
        
        skuMap.merge(consumablesSkuModelMap()) { (_, new) in new }
        
        return skuMap
    }
    
    /// 订阅包
    private static func subscriptionSkuModelMap() -> [String: SkuBaseModel] {
        AppEvoConfig.skuConfig.reduce(into: [:]) { partialResult, item in
            partialResult[item.skuId] = item.toSkuModel()
        }
    }
    
    /// 订阅中的家庭包
    static func subscriptionFamilySkuModelMap() -> [String: SkuBaseModel]  {
        return [:]
    }
    
    /// 一次性消费包
    static func consumablesSkuModelMap() -> [String: SkuBaseModel] {
        return [:]
    }
    
    static var trialSkus: [String] {
        let skus: Set<String> = self.purchaseSkus.reduce(into: []) { partialResult, element in
            if let model = element.value as? SkuSubscriptionModel, model.isTrail {
                partialResult.insert(model.sku)
            }
        }
        return Array(skus)
    }
    
    static var familySkus: [String] {
        return []
    }
}
