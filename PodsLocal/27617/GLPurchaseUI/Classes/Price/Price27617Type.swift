//
//  PriceType.swift
//  Vip27584
//
//  Created by Martin on 2024/8/22.
//

import Foundation
import GLCore
import GLPurchaseExtension

struct Price {
    let price: String
    let dayPrice: String?
}

@objc
public enum Price27617Type: Int, CaseIterable {
    case week
    case year
    
    static var `default`: Price27617Type {
        return .year
    }
    
    var skuId: String {
        switch self {
            case .week:
                return "BeVocal_sub_week"
            case .year:
                return "BeVocal_sub_year"
        }
    }
    
    var price: Price? {
        guard let sku = GL().Purchase_GetSkuModel(forId: self.skuId)?.sku, let product = GL().Purchase_FetchProductFromCache(sku) else { return nil }
        var dayPrice: String? = nil
        if self == .year {
            dayPrice = product.multyPrice(by: 1/365.0)
        } else if self == .week {
            dayPrice = product.multyPrice(by: 1 / 7.0)
        }
        return Price(price: product.priceDescription, dayPrice: dayPrice)
    }
    
    var trailDays: Int {
        GL().Purchase_GetSkuModel(forId: self.skuId)?.toSubscriptionModel?.trailDays ?? 3
    }
    
    var trailable: Bool {
        self.trailDays > 0
    }
    
    var priceText: String {
        let price = self.price
        switch self {
            case .week:
                return "conversionpage_price_week".localized(for: Vip27617AContentView.self,
                                                             tableName: "Localizable27617",
                                                             price?.price ?? "?", price?.dayPrice ?? "?")
            case .year:
                return "conversionpage_price_year".localized(for: Vip27617AContentView.self,
                                                             tableName: "Localizable27617",
                                                             price?.price ?? "?", price?.dayPrice ?? "?")
        }
    }
}
