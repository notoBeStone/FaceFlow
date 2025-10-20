//
//  PurchaseUI.swift
//  AINote
//
//  Created by Martin on 2022/10/21.
//

import Foundation
import GLDatabase

// 移动 UserTagsConfig 中转化页关闭至 PurchaseUICache
class PurchaseUICache {
    private static let storeConversionCloseKey = "conversionpage_closed_inhistory_storekey"
    
    private class var conversionpageClosedTimesInhistory: String {
        return "\(GLCache.integer(forKey: storeConversionCloseKey))"
    }
    
    @objc
    public class func updateConversionPageClosedTimesInHistory() {
        let nowTimes = GLCache.integer(forKey: storeConversionCloseKey)
        GLCache.setInteger(nowTimes + 1, forKey: storeConversionCloseKey)
    }
}
