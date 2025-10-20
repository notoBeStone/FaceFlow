/**
 * @file Concurrency.swift
 * @brief 并发相关
 * @author wang.zhilong
 * @date 2024-12-06
 */

import Foundation

/// 全局 Actor 用于数据库操作隔离
@globalActor public final actor GLBizStorageActor {
    public static let shared = GLBizStorageActor()
    private init() {}
    
    // 实例方法
    public func run<T>(body: @Sendable () throws -> T) throws -> T {
        return try body()
    }
    
    public func run<T>(body: @Sendable () async throws -> T) async throws -> T {
        return try await body()
    }
    
    public func run<T>(body: @Sendable () -> T) -> T {
        return body()
    }
    
    public func run<T>(body: @Sendable () async -> T) async -> T {
        return await body()
    }
    
    // 静态方法需要标记为 async
    public static func run<T>(body: @GLBizStorageActor @Sendable () throws -> T) async throws -> T {
        return try await shared.run(body: body)
    }
    
    public static func run<T>(body: @GLBizStorageActor @Sendable () async throws -> T) async throws -> T {
        return try await shared.run(body: body)
    }
    
    public static func run<T>(body: @GLBizStorageActor @Sendable () -> T) async -> T {
        return await shared.run(body: body)
    }
    
    public static func run<T>(body: @GLBizStorageActor @Sendable () async -> T) async -> T {
        return await shared.run(body: body)
    }
}