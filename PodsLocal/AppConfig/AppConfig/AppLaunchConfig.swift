//
//  AppLaunchConifg.swift
//  GLModules
//
//  Created by user on 2024/6/20.
//

import Foundation
import GLUtils

public struct AppLaunchConfig {
    
    //Agreement Memo
//    public static let agreementMemo: String = "PT"
    public static let agreementMemo: String? = nil
    
    //MARK: - GLWebImage
    
    //图片缓存过期时间
    public static let imageMaxCachePeriod: Int = 30 * 24 * 3600
    public static let defaultPlaceholderImage: UIImage? = UIImage(named: "blank")
    public static let defaultPlaceholderBackgroundColor: UIColor = .gl_color(0x151B2A, alpha: 0.15)
    
//    //MARK: - NPS
//    //注意请在用户初始化结束前设置
//    public static var npsExcludedClasses: [AnyClass] = []
//    public static var nspExcludedClassName: [String] = []
    
    
}
