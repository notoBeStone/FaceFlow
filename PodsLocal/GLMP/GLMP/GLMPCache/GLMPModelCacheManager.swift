//
//  GLMPModelCacheManager.swift
//  GLMP
//
//  Created by Martin on 2024/11/27.
//

import Foundation

public struct GLMPModelCacheManager<T: Codable> {
    let cache: GLMPModelCache<T>
    public private(set) var datas: T?
    
    public init(key: String, versionData: GLMPModelCacheVersionData? = nil) {
        let cache = GLMPModelCache<T>(key: key, versionData: versionData)
        self.cache = cache
        self.datas = cache.data
    }
    
    mutating public func setData(_ data: T?) {
        cache.data = data
        self.datas = data
    }
    
    public var hasValue: Bool {
        cache.hasValue
    }
}

extension GLMPModelCacheManager {
    mutating public func appendData<Element>(_ data: Element) where T == [Element] {
        var datas: [Element] = []
        
        if let cacheDatas = self.datas {
            datas = cacheDatas
        }
        datas.append(data)
        self.setData(datas)
    }
    
    mutating public func appendDatas<Element>(_ datas: [Element]) where T == [Element] {
        var curDatas = self.datas ?? []
        curDatas.append(contentsOf: datas)
        self.setData(curDatas)
    }
}
