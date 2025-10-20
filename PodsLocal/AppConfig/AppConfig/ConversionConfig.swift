//
//  ConversionConfig.swift
//  AINote
//
//  Created by xie.longyan on 2024/6/17.
//

import Foundation
import GLUtils

private let kVipAlertDate = "kVipAlertDate"  //转化页上次打开的时间
private let kVipAlertCount = "kVipAlertCount"  //转化页同一天弹出的次数
public class ConversionConfig {
    /// 区分每日首弹和非首弹 9999A，9998A
    public static let defaultMemo: String = "9999A"
    public static let historyMemo: String = "9998A" // {$.history_memo) 客户端自行配置
}
                        
