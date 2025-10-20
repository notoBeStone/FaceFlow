/**
 * @file Schema.swift
 * @brief 数据库 schema
 * @author wang.zhilong
 * @date 2024-12-06
 */

import GRDB
import Foundation
import AppModels
import DGMessageAPI
import Combine

enum GLBizStorageSchemaUpdateType: Int {
    case add = 1
    case update = 2
    case delete = 3
    case unknown = -1
}

struct GLBizStorageSchemaUpdateInfo<T:GLBizStorageSchema> {
    let type: GLBizStorageSchemaUpdateType
    let `id`: Int64
    let item: T
}

/// 数据库 schema 协议
open class GLBizStorageSchema {
    
    public private(set) var createAt: Date
    public private(set) var updateAt: Date
    public var bizStorageId: Int64?
    
    public required init() {
        createAt = Date()
        updateAt = Date()
    }
    
    class var databaseTableName: String {
        let name = String(describing: self)
        return "glbizstorage_schema_\(name)"
    }
    
    public class var schemaType: String {
        return databaseTableName
    }
    
    static var schemaUpdatedPublisher = PassthroughSubject<GLBizStorageSchemaUpdateInfo, Never>()
    
    // schema 底层通过这个字段进行序列化和反序列化
    // 因为 底层的 bizstorage 的 API是这么设计的，为了避免本地和远端的行为不一致
    // 所以这里也这么设计
    var attributes: [String: AnyHashable] = [:]
    
    class func from<T:GLBizStorageSchema>(_ storageItem: BizStorageModel) -> T? {
        if storageItem.bizType != Self.databaseTableName {
            return nil
        }
        guard let ins = Self() as? T else {
            return nil
        }
        ins.bizStorageId = storageItem.storageId
        ins.createAt = storageItem.createdAt
        ins.updateAt = storageItem.updatedAt
        let data = storageItem.data.data(using: .utf8) ?? Data()
        let dict = (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyHashable]) ?? [:]
        ins.attributes = dict
        return ins
    }
    
    func toSaveRequest() -> BizstorageSaveStorageRequest? {
        guard let data = try? JSONSerialization.data(withJSONObject: attributes),
                let str = String(data: data, encoding: .utf8)  else {
            return nil
        }
        let request = BizstorageSaveStorageRequest(bizType: Self.databaseTableName, data: str)
        return request
    }
    
    /// 虽然和 saveRequest分开写麻烦了些，但是为了保持语义这么干
    func toUpdateRequest() -> BizstorageUpdateStorageRequest? {
        guard let data = try? JSONSerialization.data(withJSONObject: attributes),
                let str = String(data: data, encoding: .utf8)  else {
            return nil
        }
        let request = BizstorageUpdateStorageRequest(storageId: self.bizStorageId!, data: str)
        return request
    }
    
    @GLBizStorageActor
    public func save(to context: GLBizStorage) async throws {
        try await context.asyncWrite(self)
        debugPrint("save \(Self.databaseTableName) success, storageId \(self.bizStorageId ?? -1)")
    }
}

@propertyWrapper
public struct GLBizPersisted<T: Hashable> {
    private let keyPath: String

    public init(keyPath: String) {
        self.keyPath = keyPath
    }

    public static subscript<EnclosingSelf: GLBizStorageSchema>(
        _enclosingInstance instance: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, T?>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
    ) -> T? {
        get {
            let propertyName = instance[keyPath: storageKeyPath].keyPath
            return instance.attributes[propertyName] as? T
        }
        set {
            let propertyName = instance[keyPath: storageKeyPath].keyPath
            instance.attributes[propertyName] = newValue
        }
    }

    public var wrappedValue: T? {
        get { fatalError("Should not be called directly") }
        set { fatalError("Should not be called directly") }
    }
}
