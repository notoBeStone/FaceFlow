//
//  GLMPModelCache.swift
//  GLMP
//
//  Created by Martin on 2024/11/7.
//

import Foundation
import GLConfig_Extension
import GLCore

public struct GLMPModelCacheVersionData {
    public let expirationDuration: Double?  // 过期时间 单位秒
    public let version: String?  // 最新版本号

    public init(expirationDuration: Double?, version: String?) {
        self.expirationDuration = expirationDuration
        self.version = version
    }

    public init(days: Int?, version: String?) {
        if let days = days, days > 0 {
            self.expirationDuration = Double(days) * 24 * 3600
        } else {
            self.expirationDuration = nil
        }
        self.version = version
    }
}

public class GLMPModelCache<Element> where Element: Codable {
    private let key: String
    private let timeKey: String
    private let versionKey: String
    private let versionData: GLMPModelCacheVersionData?
    private var _data: Element?
    public var data: Element? {
        set {
            lock.lock()
            self.setData(newValue)
            lock.unlock()
        }
        
        get {
            let data: Element?
            lock.lock()
            data = self._data
            lock.unlock()
            return data
        }
    }
    
    public init(key: String, versionData: GLMPModelCacheVersionData? = nil, ignoreEnvironment: Bool = false) {
        var key = key
        if !ignoreEnvironment {
            key = key.getCurrentEnvironmentKey
        }
        self.key = key
        self.timeKey = "\(key)_time"
        self.versionKey = "\(key)_version"
        self.versionData = versionData
        self.loadData()
    }
    
    public func clear() {
        GLMPCache.set(key: self.key, value: nil)
        GLMPCache.set(key: self.versionKey, value: nil)
        GLMPCache.removeObject(for: self.timeKey)
    }
    
    public var hasValue: Bool {
        GLMPCache.contains(key: self.key)
    }
    
    private func loadData() {
        // 数据过期了
        if self.isOverdue {
            GLMPCache.set(key: self.key, value: nil)
            self._data = nil
            return
        }
        
        if let data: Data = GLMPCache.get(key: self.key),
           let element = try? JSONDecoder().decode(Element.self, from: data) {
            self._data = element
        }
    }
    
    private func setData(_ data: Element?) {
        func refreshVersion() {
            GLMPCache.set(key: self.timeKey, value: Date().timeIntervalSince1970)
            if let version = self.versionData?.version {
                GLMPCache.set(key: self.versionKey, value: version)
            }
        }
        
        self._data = data
        if let data {
            if let data = try? JSONEncoder().encode(data) {
                GLMPCache.set(key: self.key, value: data)
                refreshVersion()
            }
        } else {
            GLMPCache.set(key: self.key, value: nil)
            refreshVersion()
        }
    }
    
    // MARK: - Readonly
    private var isOverdue: Bool {
        // 最后一次保存时间
        let cacheTime: Double = GLMPCache.get(key: self.timeKey, default: 0)
        if let expirationDuration = self.versionData?.expirationDuration,
           Date().timeIntervalSince1970 - cacheTime >= expirationDuration {
            return true
        }
        
        if let version = self.versionData?.version,
           version != GLMPCache.get(key: self.versionKey) {
            return true
        }
        return false
    }
    
    // MARK: - Lazy load
    private lazy var lock = NSLock()
}

extension GLMPModelCache {
    public func appendData<T>(_ data: T) where Element == [T] {
        var datas: [T] = []

        if let cacheDatas = self.data {
            datas = cacheDatas
        }
        datas.append(data)
        self.data = datas
    }

    public func appendDatas<T>(_ datas: [T]) where Element == [T] {
        var curDatas = self.data ?? []
        curDatas.append(contentsOf: datas)
        self.data = curDatas
    }
}

extension String {
    fileprivate var getCurrentEnvironmentKey: String {
        var suffix = "stage"
        if GL().GLConfig_currentEnvironmentIsProduction() {
            suffix = "production"
        }

        return "\(self)_\(suffix)"
    }
}
