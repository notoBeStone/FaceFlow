//
//  VipHistoryManager.swift
//  DangJi
//
//  Created by fans on 2021/11/9.
//  Copyright © 2021 Glority. All rights reserved.
//

import AppConfig
import Foundation
import GLCore
import GLDatabase
import GLMP
import GLPurchaseExtension
import GLTrackingExtension

private let VipHistoryManagerSaveKey = "VipHistoryManagerSaveKey_0"
private let VipHistoryFamilyShareSaveKey = "VipHistoryFamilyShareSaveKey"

@objc
public class VipHistoryManager: NSObject {

    @objc static public let shared = VipHistoryManager()
    @objc public var isVipInHistory: Bool {
        (GLMPAccount.getUserAdditionalData()?.isVipInHistory.boolValue ?? false) || isBought
    }

    @objc public var isVipFamilyShared: Bool {
        return isFamily
    }

    private var isBought: Bool = false
    private var isFamily: Bool = false

    @objc
    public func setup() {
        if #available(iOS 15.0, *) {
            if hasStorage() {
                isBought = getStorageValue()
            }
            if let familyShared = GLCache.object(forKey: VipHistoryFamilyShareSaveKey) as? NSNumber {
                self.isFamily = familyShared.boolValue
            }
            let list = SKUConfig.subscriptionSkuList()
            guard list.count > 0 else {
                return
            }

            let beginTime = Date().timeIntervalSince1970

            GL().Purchase_IsEverPaid(list) { [weak self] paid, isFamily, productId in
                guard let self = self else { return }
                self.isBought = paid
                self.storage(isBought: paid)
                let time = Date().timeIntervalSince1970 - beginTime
                if paid {
                    GL().Tracking_Event("is_vip_history_get_success", parameters: [GLT_PARAM_TIME: time])
                }
            }
            GL().Purchase_IsEverPaid(SKUConfig.subscriptionFamilySkuList()) { [weak self] paid, isFamily, productId in
                guard let self = self else { return }
                if paid {
                    self.store(isFamily: isFamily)
                    self.isFamily = isFamily
                }
            }
        }
    }

    private func storage(isBought: Bool) {
        let obj = NSNumber(booleanLiteral: isBought)
        GLCache.setObject(obj, forKey: VipHistoryManagerSaveKey)
    }

    private func store(isFamily: Bool) {
        GLCache.setObject(NSNumber(booleanLiteral: isFamily), forKey: VipHistoryFamilyShareSaveKey)
    }

    private func hasStorage() -> Bool {
        GLCache.object(forKey: VipHistoryManagerSaveKey) != nil
    }

    private func getStorageValue() -> Bool {
        guard let obj = GLCache.object(forKey: VipHistoryManagerSaveKey) as? NSNumber else {
            return false
        }
        return obj.boolValue
    }
}
