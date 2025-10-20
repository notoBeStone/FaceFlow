//
//  AppServerHostDebugger.swift
//  AppServerHostDebugger
//
//  Created by xie.longyan on 2022/9/2.
//

import Foundation
import GLUtils
import GLDebugger
import GLDatabase
import GLConfig
import GLWidget
import GLUtils
import GLCore
import GLConfig_Extension

let AppServerHostDebuggerHostKey = "AppServerHostDebuggerHostKey"
let AppServerHostDebuggerCustomHostsKey = "AppServerHostDebuggerCustomHostsKey"

@objc public class AppServerHostDebugger: NSObject {

    @objc public static var shared = AppServerHostDebugger()
    
    var hostModels: GLSafeArray<HostDebuggerModel>
    
    @objc public var selectedHostModel: HostDebuggerModel? {
        return hostModels.first(where: { $0.isSelected })
    }
    
    override init() {
        var models: [HostDebuggerModel] = []
      
        // Default Env
        let envs = AppEnv.allCases
        for env in envs {
            switch env {
            case .prod:
                models.append(.init(type: .config, title: "Prod", host: env.mainHost, env: .prod))
            case .stage:
                models.append(.init(type: .config, title: "Stag", host: env.mainHost, env: .stage))
            case .test:
                break
            }
        }

        // Custom Env
        let customs = AppServerHostDebugger.getCustomCacheModels()
        if customs.count > 0 {
            models.append(contentsOf: customs)
        }

        let selectedHost = GLCache.string(forKey: AppServerHostDebuggerHostKey) ?? GLConfig.debugger_env.mainHost
        for hostModel in models {
            hostModel.isSelected = hostModel.host == selectedHost
        }
        
        self.hostModels = GLSafeArray<HostDebuggerModel>(elements: models)
        
        super.init()
    }
    
    func select(_ selectedHostModel: HostDebuggerModel) {
        for (_, hostModel) in self.hostModels.enumerated() {
            hostModel.isSelected = hostModel.host == selectedHostModel.host
            if hostModel.isSelected {
#warning("todo 考虑hook")
                GLCache.setString(hostModel.host, forKey: AppServerHostDebuggerHostKey)
                exit(0)
            }
        }
    }
    
    func delete(_ hostModel: HostDebuggerModel) {
        let isCustom = hostModel.type == .custom
        self.hostModels.removeAll(where: { $0.host == hostModel.host })
        AppServerHostDebugger.deleteCustomModel(hostModel)
        
        if hostModel.isSelected && isCustom {
            for (_, model) in self.hostModels.enumerated() {
                if model.host == GL().GLConfig_GetMainHost() {
                    self.select(model)
                    return
                }
            }
        }
    }
    
    func appendCustomHostModel(_ customHostModel: HostDebuggerModel) {
        if self.hostModels.contains(where: { $0.host == customHostModel.host }) {
            GLToast.showError("已经存在该 Host")
            return
        }
        
        self.hostModels.append(customHostModel)
        AppServerHostDebugger.cacheCustomModel(customHostModel)
    }
    
    static func getCustomCacheModels() -> [HostDebuggerModel] {
        guard let jsonString = GLCache.string(forKey: AppServerHostDebuggerCustomHostsKey) else {
            return []
        }
        return self.decodeToModels(jsonString)
    }
    
    static func cacheCustomModel(_ customHostModel: HostDebuggerModel) {
        var models = getCustomCacheModels()
        guard !models.contains(where: { $0.host == customHostModel.host } ) else {
            return
        }
        models.append(customHostModel)
        if let jsonString = self.encodeToJson(models) {
            GLCache.setString(jsonString, forKey: AppServerHostDebuggerCustomHostsKey)
        }
    }
    
    static func deleteCustomModel(_ customHostModel: HostDebuggerModel) {
        var models = getCustomCacheModels()
        guard models.contains(where: { $0.host == customHostModel.host } ) else {
            return
        }
        models.removeAll(where: { $0.host == customHostModel.host })
        if let jsonString = self.encodeToJson(models) {
            GLCache.setString(jsonString, forKey: AppServerHostDebuggerCustomHostsKey)
        }
    }
    
    static private func encodeToJson(_ models: [HostDebuggerModel]) -> String? {
        if let jsonData = try? JSONEncoder().encode(models) {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }
    
    static private func decodeToModels(_ jsonString: String) -> [HostDebuggerModel] {
        if let jsonData = jsonString.data(using: .utf8),
           let array = try? JSONDecoder().decode([HostDebuggerModel].self, from: jsonData) {
            return array
        }
        return []
    }
    
    lazy var debuggerWindow: AppServerHostDebuggerWindow = {
        let window = AppServerHostDebuggerWindow()
        return window
    }()
}


extension AppServerHostDebugger {
    @objc static public var serverAddress: String? {
        guard let mainHost = mainHost else {
            return nil
        }
        return mainHost + "/api"
    }
    
    @objc static public var mainHost: String? {
        guard let host = AppServerHostDebugger.shared.selectedHostModel?.host, host.count > 0 else {
            return nil
        }
        return host
    }
    
    class public var env: AppEnv? {
        guard let model = AppServerHostDebugger.shared.selectedHostModel else {
            return nil
        }
        return model.env
    }
}
