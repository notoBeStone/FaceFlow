//
//  BizStorageImp.swift
//  AquaAI
//
//  Created by stephenwzl on 2025/6/17.
//

import Foundation
import AppModels
import GLMP

extension RemoteDBAPI {
    static func storageObject(_ data: String, schema: String) async throws -> RemoteDBObject {
        guard schema.isEmpty == false, data.isEmpty == false else {
            throw RemoteDBError.invalidRequest
        }
        let request = BizstorageSaveStorageRequest(bizType: schema, data: data)
        let res = await GLMPNetwork.request(request)
        if let error = res.error {
            throw RemoteDBError.operationFailed(error.localizedDescription)
        }
        guard let responseObject = res.data else {
            throw RemoteDBError.unknownError
        }
        return RemoteDBObject(id: responseObject.storageId, object: data, createAt: .now, updateAt: .now, schema: schema)
    }
    
    static func listObjects(_ schema: String, lastId: Int64? = nil, pageSize: Int = 100) async throws -> RemoteDBListObjectsResponse {
        guard schema.isEmpty == false else {
            throw RemoteDBError.invalidRequest
        }
        let request = BizstorageListStoragesRequest(bizType: schema, lastId: lastId, pageSize: pageSize)
        let res = await GLMPNetwork.request(request)
        if let error = res.error {
            throw RemoteDBError.operationFailed(error.localizedDescription)
        }
        guard let responseObject = res.data else {
            throw RemoteDBError.unknownError
        }
        let objects = responseObject.list.map { model in
            RemoteDBObject(id: model.storageId, object: model.data, createAt: model.createdAt, updateAt: model.updatedAt, schema: model.bizType)
        }
        return RemoteDBListObjectsResponse(schema: schema, objects: objects, total: responseObject.total)
    }
    
    static func updateObject(_ data: String, id: Int64) async throws {
        guard data.isEmpty == false else {
            throw RemoteDBError.invalidRequest
        }
        let request = BizstorageUpdateStorageRequest(storageId: id, data: data)
        let res = await GLMPNetwork.request(request)
        if let error = res.error {
            throw RemoteDBError.operationFailed(error.localizedDescription)
        }
    }
    
    static func getObject(_ id: Int64) async throws -> RemoteDBObject {
        guard id >= 0 else {
            throw RemoteDBError.invalidRequest
        }
        let request = BizstorageGetStorageByIdRequest(storageId: id)
        let res = await GLMPNetwork.request(request)
        if let error = res.error {
            throw RemoteDBError.operationFailed(error.localizedDescription)
        }
        guard let obj = res.data?.storage else {
            throw RemoteDBError.unknownError
        }
        return RemoteDBObject(id: obj.storageId, object: obj.data, createAt: obj.createdAt, updateAt: obj.updatedAt, schema: obj.bizType)
    }
    
    static func deleteObject(_ id: Int64) async throws {
        guard id >= 0 else {
            throw RemoteDBError.invalidRequest
        }
        let request = BizstorageDeleteStorageRequest(storageId: id)
        let res = await GLMPNetwork.request(request)
        if let error = res.error {
            throw RemoteDBError.operationFailed(error.localizedDescription)
        }
    }
}
