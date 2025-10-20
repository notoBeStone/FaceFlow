/**
 * @file Query.swift
 * @brief 数据库查询构建器
 * @author wang.zhilong
 * @date 2024-12-06
 */

import Foundation
import AppModels
import GRDB

// TODO: 貌似 bizstorage 接口是从老到新查的
public class Query<T: GLBizStorageSchema> {
    /// 查询条件
    /// 谨慎使用属性查找，因为属性查找需要遍历HTTP API接口，可能会造成性能问题
    /// 该组件的设计如此，如果没有开启远程数据，则不会进行网络请求，性能瓶颈是SQLite的读取
    /// 海量数据请谨慎使用，分清楚是本地数据还是远程数据
    public var filters: [String: AnyHashable] = [:]
    /// 分页大小
    var pageSize: Int = 100
    /// 最后一个ID
    private var lastId: Int64?
    
    public init() {}
    
    /// 添加查询条件
    /// - Parameters:
    ///   - key: 属性名
    ///   - value: 属性值
    /// - Returns: Query 实例
    @discardableResult
    public func filter(_ key: String, _ value: AnyHashable) -> Self {
        filters[key] = value
        return self
    }
    
    /// 设置分页大小
    /// - Parameter size: 分页大小
    /// - Returns: Query 实例
    @discardableResult
    public func limit(_ size: Int) -> Self {
        self.pageSize = size
        return self
    }
    
    /// 设置起始ID
    /// - Parameter id: 最后一个ID
    /// - Returns: Query 实例
    @discardableResult
    public func after(id: Int64) -> Self {
        self.lastId = id
        return self
    }
    
    /// 构建 BizStorage 请求
    /// - Returns: BizstorageListStoragesRequest
    func toBizStorageRequest() -> BizstorageListStoragesRequest {
        // 获取模型类名作为 bizType
        let bizType = T.databaseTableName
        
        return BizstorageListStoragesRequest(
            bizType: bizType,
            lastId: lastId,
            pageSize: pageSize
        )
    }
    
    /// 重置查询条件
    public func reset() {
        filters.removeAll()
        lastId = nil
    }
    
    /// 构建 GRDB 查询条件
    /// - Returns: SQL 查询条件
    func toSQLQuery(userId: Int64) -> QueryInterfaceRequest<GLBizStorageRecord> {
        var query = GLBizStorageRecord
            .filter(Column("user_id") == userId)
            .filter(Column("biz_type") == T.databaseTableName)
        
        // 添加 ID 分页条件
        if let lastId = lastId {
            query = query.filter(Column("id") < lastId)
        }
        
        // 添加属性过滤条件
        if !filters.isEmpty {
            // 将 filters 转换为 JSON 格式的字符串条件
            let conditions = filters.map { key, value in
                let jsonValue = (try? JSONSerialization.data(withJSONObject: [key: value])) ?? Data()
                let jsonString = String(data: jsonValue, encoding: .utf8) ?? "{}"
                return "json_extract(data, '$.\(key)') = json_extract('\(jsonString)', '$.\(key)')"
            }
            
            // 使用 SQL 表达式添加 JSON 查询条件
            query = query.filter(sql: conditions.joined(separator: " AND "))
        }
        
        // 添加排序和分页
        return query
            .order(Column("id").desc)
            .limit(pageSize)
    }
}
