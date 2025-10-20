//
//  ABTestingManager.swift
//  AINote
//
//  Created by user on 2024/4/3.
//

import Foundation
import GLCore
import GLABTestingExtension

public class GLMPABTesting {
    /// 设置私有的tag, 当tag 和 公共tag 冲突时以私有tag 为准, 当多个地方设置私有tag,如果有冲突的,以最后更新的为准
    /// - Parameter tagsCallback: 在回调中返回,使得每次的tag都是最新的
    public class func setProjectPrivateTags(_ tagsCallback: @escaping () -> [String: [String]]) {
        GL().ABTesting_SetProjectPrivateTags(tagsCallback)
    }
    
    /// 从server 下载配置, 一次app生命周期只会请求一次,即调用多次,只会请求一次server,但是都会收到完成时的回调
    /// - Parameter callback: 下载完成后的回调
    public class func loadABTesting(callback: @escaping (Bool, String) -> Void) {
        GL().ABTesting_LoadABTesting(callback: callback)
    }
    
    ///异步接口封装
    public class func loadABTesting() async -> (Bool, String) {
        return await withCheckedContinuation { continuation in
            GLMPABTesting.loadABTesting { success, message in
                continuation.resume(returning: (success, message))
            }
        }
    }
    
    /// 查询带有某个字段开头的所有abtest group name 并且返回 查询结束带有variable variableData 的模型,传递空字符串"",则返回所有abtestname
    /// - Parameters:
    ///   - name: 以该名字为前缀
    ///   - activate: 是否激活
    /// - Returns: 返回查询到的数组
    public class func queryABTestingModels(_ groupNamePrefix: String, activte: Bool = true) -> [GLABTestingModel] {
        GL().ABTesting_QueryABTestingModelsHasGroupNamePrefix(groupNamePrefix, activate: activte)
    }
    
    /// 通过groupname的前缀 查找所有的keys
    public class func queryABTestingKeys(_ groupNamePrefix: String) -> [String] {
        GL().ABTesting_QueryABTestingKeysHasGroupNamePrefix(groupNamePrefix)
    }
}


// MARK: - GLMP API
extension GLMPABTesting {
    /// 通过key获取abtest的variable
    /// - Parameters:
    ///   - key: key
    ///   - activate: 是否激活,true 表示会发送相关分配埋点, false 表示不发送埋点, 埋点只在记录时发送一次,后续不再发送
    /// - Returns: value的值
    public class func variable(key: String, activate: Bool = true) -> String? {
        GL().ABTesting_ValueForKey(key, activate: activate)
    }
    
    /// 通过key获取abtest的variableData
    /// - Parameters:
    ///   - key: key
    ///   - activate: 是否激活,true 表示会发送相关分配埋点, false 表示不发送埋点, 埋点只在记录时发送一次,后续不再发送
    /// - Returns: value的值
    public class func variableData(key: String, activate: Bool = true) -> String? {
        let model = variableModel(key: key, activate: activate)
        return model?.variableData
    }
    
    /// 通过key获取abtest 的model
    /// - Parameters:
    ///   - key: key
    ///   - activate: 是否激活,true 表示会发送相关分配埋点, false 表示不发送埋点, 埋点只在记录时发送一次,后续不再发送
    /// - Returns: abtest 的模型
    public class func variableModel(key: String, activate: Bool = true) -> GLABTestingModel? {
        GL().ABTesting_VariableModelForKey(key, activate: activate)
    }
    
    /// 发送相关key的埋点, 仅在参与ab测试的用户进入相关功能时调用该方法来进行分群,使用效果跟获取ab的值时 activate置为true效果相同
    /// - Parameter key: key
    public class func activate(key: String) {
        _ = variableModel(key: key, activate: true)
    }
    
    ///  用于ab组件追踪更多数据
    /// - Parameters:
    ///   - key: ab 的key
    ///   - dataKey: 由需求方给出
    ///   - dataValue: 由需求方给出
    public class func trackMoreData(key: String, dataKey: String, dataValue: String) {
        GL().ABTesting_TrackMoreData(key: key, dataKey: dataKey, dataValue: dataValue)
    }
    
    /// 会将featureName持久化并拼接到 'ab_used_features' 的内容里面,表示用过那些feature, featureName需要业务方自己定义
    public class func addUsedFeature(_ featureName: String) {
        GL().ABTesting_AddUsedFeature(featureName)
    }
}


// MARK: - Debugger
extension GLMPABTesting {
    public class func registerDebugger() {
        GL().ABTesting_RegisterDebugger()
    }
    
    public class func debuggerTurnToDefaultMode() {
        GL().ABTesting_DebuggerTurnToDefaultMode()
    }
    
    public class func debuggerTurnToNormalMode() {
        GL().ABTesting_DebuggerTurnToNormalMode()
    }
    
    public class func debuggerMapKey(_ key: String, to value: String, variableData: String?) {
        GL().ABTesting_DebuggerMapKey(key, to: value, variableData: variableData)
    }
}
