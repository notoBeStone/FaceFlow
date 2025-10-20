//
//  GLMPCacheWrapper.swift
//  GLMP
//
//  Created by xie.longyan on 2024/7/12.
//

import Foundation
import GLCore
import GLConfig_Extension

public class GLMPCacheWrapper<T: Codable> {

    private let cacheKey: String
    private var _cacheData: T?
    private let lock = DispatchSemaphore(value: 1)

    private func Lock() {
        lock.wait()
    }

    private func Unlock() {
        lock.signal()
    }

    private func getCachedData() -> T? {
        Lock()
        defer { Unlock() }
        if _cacheData == nil {
            _cacheData = GLMPCache.get(key: cacheKey)
        }
        return _cacheData
    }

    private func setCachedData(_ newValue: T?) {
        Lock()
        defer { Unlock() }
        _cacheData = newValue
        GLMPCache.set(key: cacheKey, value: newValue)
    }

    public var cacheData: T? {
        get {
            return getCachedData()
        }
        set {
            setCachedData(newValue)
        }
    }

    public init(key: String) {
        var cacheKeySuffix = ""
        if GL().GLConfig_currentEnvironmentIsProduction() {
            cacheKeySuffix = ".cache0"
        } else if GL().GLConfig_currentEnvironmentIsStage() {
            cacheKeySuffix = ".cache1"
        } else {
            cacheKeySuffix = ".cache2"
        }
        self.cacheKey = key + cacheKeySuffix
    }
}

extension GLMPCacheWrapper where T: Equatable {

    public var cacheData: T? {
        get {
            return getCachedData()
        }
        set {
            Lock()
            defer { Unlock() }
            if _cacheData != newValue {
                _cacheData = newValue
                GLMPCache.set(key: cacheKey, value: newValue)
            }
        }
    }
}
