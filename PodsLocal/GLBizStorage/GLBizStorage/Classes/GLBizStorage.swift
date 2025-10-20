/**
 * @file GLBizStorage.swift
 * @brief GLBizStorage 是一个类似于 RealmSwift 的 serverless 数据库
 * @author wang.zhilong
 * @date 2024-12-06
 */

import GRDB
import Foundation
import GLMP
import DGMessageAPI
import AppModels

// GLBizStorage 是一个类似于 RealmSwift 的 serverless 数据库
// 它使用 GRDB 作为缓存数据库，并提供了一些便捷的 API 来操作数据库
// 它支持直接将数据存储到服务端，并且客户端本地也有一份缓存数据
// 它支持 iOS 15 及以上版本

public final class GLBizStorage {
    public struct Configuration {
        var databaseName: String
        var databaseDirectory: URL
        var hostName: String?
        var enableLocalOnly: Bool
        var userId: Int64
        var disableLocal: Bool
        
        public init(userId: Int64, databaseName: String = "GLBizStorage",
                    databaseDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!,
                    remoteHost: String? = nil , enableLocalOnly: Bool = false, disableLocal: Bool = false
        ) {
            self.userId = userId
            self.databaseName = databaseName
            self.databaseDirectory = databaseDirectory
            self.hostName = remoteHost
            self.enableLocalOnly = enableLocalOnly
            self.disableLocal = disableLocal
        }
    }
    
    private var configuration: Configuration
    // GRDB database connection configuration
    var dbQueue: DatabaseQueue?
    
    /// 初始化 GLBizStorage
    /// - Parameter configuration: 配置 默认使用 GLBizStorage 作为数据库名称，并且将数据库存储到 document 目录下
    @GLBizStorageActor
    public init(configuration: Configuration) throws {
        self.configuration = configuration
        if !configuration.disableLocal {
            self.dbQueue = try DatabaseQueue(path: configuration.databaseDirectory.appendingPathComponent("\(configuration.databaseName).sqlite").path)
            try setupDatabase()
        }
    }
}


public extension GLBizStorage {
    @GLBizStorageActor
    func asyncDelete<T: GLBizStorageSchema>(_ schema: T) async throws {
        guard let bizStorageId = schema.bizStorageId else {
            throw GLBizStorageError.requestError
        }
        let request = BizstorageDeleteStorageRequest(storageId: bizStorageId)
        let res = await GLMPNetwork.request(request)
        try handleCommonRes(res)
        await MainActor.run {
            let schemaType = type(of: schema).schemaType
            type(of: schema).schemaUpdatedPublisher.send(GLBizStorageSchemaUpdateInfo(type: .delete,
                                                                                      id: bizStorageId,
                                                                                      item: schema))
        }
        
    }
    
    /// update 和 save是一起的，现在缺一个服务端存储后的 id 返回，现在需要每次都去查最新的
    @GLBizStorageActor
    func asyncWrite<T: GLBizStorageSchema>(_ schema: T) async throws {
        if let bizStorageId = schema.bizStorageId {
            if let request = schema.toUpdateRequest() {
                let res = await GLMPNetwork.request(request)
                try handleCommonRes(res)
                await MainActor.run {
                    let schemaType = type(of: schema).schemaType
                    type(of: schema).schemaUpdatedPublisher.send(GLBizStorageSchemaUpdateInfo(type: .update,
                                                                                              id: bizStorageId,
                                                                                              item: schema))
                }
            } else {
                throw GLBizStorageError.serializationError
            }
        } else {
            if let request = schema.toSaveRequest() {
                let res = await GLMPNetwork.request(request)
                try handleCommonRes(res)
                schema.bizStorageId = res.data?.storageId
                await MainActor.run {
                    let schemaType = type(of: schema).schemaType
                    type(of: schema).schemaUpdatedPublisher.send(GLBizStorageSchemaUpdateInfo(type: .add,
                                                                                              id: schema.bizStorageId ?? -1,
                                                                                              item: schema))
                }
            } else {
                throw GLBizStorageError.serializationError
            }
        }
        return // TODO: 暂时不加本地缓存
//        // 将 attributes 转换为 JSON string
//        let jsonData = try JSONSerialization.data(withJSONObject: schema.attributes)
//        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
//            throw GLBizStorageError.serializationError
//        }
//        
//        // 创建数据库记录
//        let record = GLBizStorageRecord(
//            id: nil,  // 自动生成
//            userId: configuration.userId,
//            bizType: type(of: schema).databaseTableName,
//            data: jsonString,
//            createdAt: Date(),
//            updatedAt: Date()
//        )
//        
//        // 写入数据库
//        try insert(record)
    }
    
    private func handleCommonRes<T: APIEncodableRequest>(_ response: GLMPResponse<T>) throws -> APIJSONResponse? {
        if let error = response.error {
            throw GLBizStorageError.requestError
        }
        return response.data
    }
    
    @GLBizStorageActor
    func asyncRead<T: GLBizStorageSchema>(_ query: Query<T>) async throws -> LazyObjectCollection<T> {
        throw GLBizStorageError.itemLoadFailed
    }
    
    @GLBizStorageActor
    func asyncGet<T: GLBizStorageSchema>(_ bizStorageId: Int64) async throws -> T {
        let request = BizstorageGetStorageByIdRequest(storageId: bizStorageId)
        let response = await GLMPNetwork.request(request)
        if let error = response.error {
            throw error
        }
        if let data = response.data {
            if let item = T.from(data.storage) as? T {
                return item
            } else {
                throw GLBizStorageError.serializationError
            }
        } else {
            throw GLBizStorageError.itemLoadFailed
        }
    }
}

