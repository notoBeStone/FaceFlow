//
//  GLMPCache.swift
//  Adjust
//
//  Created by xie.longyan on 2024/5/31.
//

import Foundation
import GLDatabase
import DGMessageAPI

public class GLMPCache {
    
    private static let lock = DispatchSemaphore(value: 1)

    private static func Lock() {
        lock.wait()
    }

    private static func Unlock() {
        lock.signal()
    }
    
    public static func set(key: String, value: Codable?) {
        Lock()
        defer { Unlock() }

        guard let value else {
            GLCache.setObject(nil, forKey: key)
            return
        }
        switch value {
        case let value as Bool:
            GLCache.setBool(value, forKey: key)
        case let value as Int:
            GLCache.setInteger(value, forKey: key)
        case let value as Float:
            GLCache.setFloat(value, forKey: key)
        case let value as Double:
            GLCache.setDouble(value, forKey: key)
        case let value as String:
            GLCache.setString(value, forKey: key)
        case let value as Data:
            GLCache.setData(value, forKey: key)
        default:
            do {
                let data = try DGJSONEncoder.default.encodeAsData(value)
                GLCache.setData(data, forKey: key)
            } catch {
                debugPrint("[GLMPCache] set (KEY:\(key), VALUE:\(value)) failed: \(error).")
            }
        }
    }
    
    public static func get<T: Codable>(key: String, default value: T) -> T {
        return get(key: key) ?? value
    }
    
    public static func get<T: Codable>(key: String) -> T? {
        Lock()
        defer { Unlock() }

        if let cachedValue = GLCache.cache.object(forKey: key) as? T {
            return cachedValue
        } else if let data = GLCache.data(forKey: key) {
            do {
                return try DGJSONDecoder.default.decode(T.self, fromData: data)
            } catch {
                debugPrint("[GLMPCache] get (KEY:\(key)) failed: \(error).")
                return nil
            }
        }
        return nil
    }
    
    public static func contains(key: String) -> Bool {
        GLCache.contains(forKey: key)
    }
    
    public static func removeObject(for key: String) {
        GLCache.removeObject(forKey: key)
    }
}
