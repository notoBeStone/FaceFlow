//
//  AppServerHostDebuggerPlugin.swift
//  AppServerHostDebugger
//
//  Created by xie.longyan on 2022/9/2.
//

import Foundation
import GLDebugger

public struct AppServerHostDebuggerPlugin: GLDebuggerPlugin {
    
    public var pluginRole: GLDebuggerPluginRole = .all
    
    public var pluginName: String = "Server"
    
    public var pluginCategoryName: String = "App内调试工具"
        
    public var pluginIconName: String? = nil
        
    public var pluginCharIconText: String? = "Host"
    
    public var pluginCharIconFont: UIFont? = .systemFont(ofSize: 12)
        
    public init() {}
    
    public func pluginDidClick(collectionView: UICollectionView, indexPath: IndexPath) {
        if AppServerHostDebugger.shared.debuggerWindow.isHidden {
            AppServerHostDebugger.shared.debuggerWindow.show()
        } else {
            AppServerHostDebugger.shared.debuggerWindow.hide()
        }
    }
}
