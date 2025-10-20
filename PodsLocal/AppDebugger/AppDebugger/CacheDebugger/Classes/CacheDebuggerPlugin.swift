//
//  CacheDebuggerPlugin.swift
//  CacheDebugger
//
//  Created by xie.longyan on 2022/9/2.
//

import Foundation
import GLDebugger

public struct CacheDebuggerPlugin: GLDebuggerPlugin {
    
    public var pluginRole: GLDebuggerPluginRole = .all
    
    public var pluginName: String = "Cache"
    
    public var pluginCategoryName: String = "App内调试工具"
        
    public var pluginIconName: String? = nil
        
    public var pluginCharIconText: String? = "Cache"
    
    public var pluginCharIconFont: UIFont? = .systemFont(ofSize: 12)
        
    public init() {}
    
    public func pluginDidClick(collectionView: UICollectionView, indexPath: IndexPath) {
        if CacheDebugger.shared.debuggerWindow.isHidden {
            CacheDebugger.shared.debuggerWindow.show()
        } else {
            CacheDebugger.shared.debuggerWindow.hide()
        }
    }
}
