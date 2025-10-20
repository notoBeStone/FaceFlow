//
//  GLMPDAOProtocol.swift
//  CoreDataDemo
//
//  Created by xie.longyan on 2024/5/30.
//

import Foundation
import GRDB

// MARK: - Model
public protocol GLMPDAOModel: GLMPDBLiveDataModel {
    /// 指定关联的 Entity
    associatedtype Entity: GLMPDAOEntity
    
    /// Model to Entity
    static func toEntity(model: Self) -> Entity
}


// MARK: - Entity
public protocol GLMPDAOEntity: GLMPDBLiveDataEntity, FetchableRecord, MutablePersistableRecord {
    /// 指定关联的 Model
    associatedtype Model: GLMPDAOModel
    
    /// 指定主键值
    var id: String { get }
    
    /// Entity to Model
    static func toModel(entity: Self) -> Model?
    
    
    static func createTable(in db: Database) throws
}
