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
public enum Price27616Type: Int, CaseIterable {
    case week
    case year
    
    static var `default`: Price27616Type {
        return .week
    }
    
    var skuId: String {
        switch self {
            case .week:
                return "BeVocal_sub_week_3dt"
            case .year:
                return "BeVocal_sub_year"
        }
    }
    
    var price: Price? {
        guard let sku = GL().Purchase_GetSkuModel(forId: self.skuId)?.sku, let product = GL().Purchase_FetchProductFromCache(sku) else { return nil }
        var dayPrice: String? = nil
        if self == .year {
            dayPrice = product.multyPrice(by: 1/365.0)
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
            case .year:
                return "conversionpage_price_year".localized(for: Vip27616AContentView.self,
                                                             tableName: "Localizable27616",
                                                             price?.price ?? "?", price?.dayPrice ?? "?")
            case .week:
                return "conversionpage_price_freeforxdaysthen".localized(for: Vip27616AContentView.self,
                                                                         tableName: "Localizable27616",
                                                                         "\(self.trailDays)", price?.price ?? "?")
        }
    }
}
