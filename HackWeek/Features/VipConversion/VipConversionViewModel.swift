//
//  VipConversionViewModel.swift
//  AquaAI
//
//  Created by stephenwzl on 2025/7/1.
//

import Foundation
import StoreKit

// 使用 TemplateAPI.swift 中定义的 ConversionSku，并使其满足在 SwiftUI 中使用的协议
extension ConversionSku: Identifiable, Hashable {
    public var id: String { skuId }
    
    public static func == (lhs: ConversionSku, rhs: ConversionSku) -> Bool {
        return lhs.skuId == rhs.skuId
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(skuId)
    }
}

// 迁移的 VipConversionFeature 逻辑 - 兼容 iOS 15
class VipConversionViewModel: ObservableObject {
    lazy var availableSkus: [String] = {
        switch memoType {
            case "27622":
                return [
                    "faceflow_sub_week_3dt",
                    "faceflow_sub_week_7dt_099"
                ]
            default:
                return [
                    "faceflow_sub_week_3dt",
                    "faceflow_sub_week_7dt_099"
                ]
        }
    }()
    
    let memoType: String
    
    init(memoType: String) {
        self.memoType = memoType
    }
    
    @Published var reminderEnable = false
    @Published var skus: [ConversionSku] = []
    @Published var selectedSkuId: String?
    
    // 是否是 iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    @MainActor
    func fetchSkus() async {
        print("Fetching skus...")
        
        let fetchedSkus = await Task.detached {
            self.availableSkus.compactMap { skuId -> ConversionSku? in
                return TemplateAPI.Conversion.fetchSkuInfo(skuId)
            }
        }.value
        
        self.skus = fetchedSkus
        // 默认选中第一个SKU
        if selectedSkuId == nil {
            self.selectedSkuId = fetchedSkus.first?.skuId
        }
        print("Skus fetched successfully.")
    }
    
    // 关闭按钮点击
    @MainActor func closeButtonTapped() {
        TemplateAPI.Conversion.closePage()
    }
    
    // 选择 SKU
    func selectSku(_ skuId: String) {
        selectedSkuId = skuId
    }
    
    @MainActor
    func purchaseButtonTapped() {
        guard let skuId = selectedSkuId,
              let sku = skus.first(where: { $0.skuId == skuId }) else {
            TemplateAPI.Debugger.showDebugMessage("No SKU selected for purchase.")
            return
        }
        print("Purchasing \(sku.skuId)...")
        TemplateAPI.Conversion.startPurchase(sku.skuId, trialable: sku.trialDays > 0)
    }
    
    @MainActor
    func restoreButtonTapped() {
        print("Restoring purchase...")
        TemplateAPI.Conversion.restorePurchase()
    }
    
    @MainActor
    func openTerms() {
        print("Opening terms...")
        TemplateAPI.Conversion.showTermsOfUse()
    }
    
    @MainActor
    func openSubscriptionTerms() {
        TemplateAPI.Conversion.showSubscriptionTerms()
    }
    
    @MainActor
    func openPrivacy() {
        print("Opening privacy policy...")
        TemplateAPI.Conversion.showPrivacyPolicy()
    }
}
