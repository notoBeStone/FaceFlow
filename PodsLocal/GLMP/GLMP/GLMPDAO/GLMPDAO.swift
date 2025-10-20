//
//  GLMPDAO.swift
//  CoreDataDemo
//
//  Created by xie.longyan on 2024/5/30.
//

import Foundation
import GLUtils
import GRDB

// MARK: - Protocol Implementation
public protocol GLMPDAOProtocol {
    associatedtype Entity: GLMPDAOEntity where Entity.Model: GLMPDAOModel
    
    /// Insert or replace
    func insertOrReplace(_ items: [Entity.Model])
    
    /// Get All
    @discardableResult func getAll(completion: ((_ items: [Entity.Model]) -> Void)?) -> LiveData<[Entity.Model]>
    /// Get Item
    func getItem(_ id: String) async -> Entity.Model?

    /// Delete All
    func deleteAll()
    /// Delete Item
    func delete(_ items: [Entity.Model])
}

open class GLMPDAO<Entity: GLMPDAOEntity>: GLMPDAOProtocol where Entity.Model: GLMPDAOModel {
    
    
    public var allLiveData = LiveData<[Entity.Model]>()
    
    
    public var dbConfig: GLMPDBConfiguration
    
    public var cancellable: DatabaseCancellable?
    
    public init(_ dbConfig: GLMPDBConfiguration) {
        self.dbConfig = dbConfig
        
        //ValueObservation不能再此线程上tracking
        DispatchQueue.main.async {
            self.setupNotificationToken()
        }
    }
    
    deinit {
        cancellable?.cancel()
        cancellable = nil
    }
    
    open func setupNotificationToken() {
        //ValueObservation不能再此线程上tracking 确保方法在主线程调用
        let valueObservation = ValueObservation.tracking { db in
            try Entity.fetchAll(db)
        }.map { entities in
            return entities.compactMap { Entity.toModel(entity: $0) }
        }
        
        cancellable = valueObservation.start(in: dbConfig.dbWriter, scheduling: .immediate) { error in
            debugPrint("[GLMPDAO] Error db operations: \(error)")
        } onChange: { [weak self] (values: [Entity.Model]) in
            self?.allLiveData.value = values
        }
    }

    // MARK: - Public Method
    open func insertOrReplace(_ items: [Entity.Model]) {
        
        do {
            try dbConfig.dbWriter.write { db in
                try items.forEach { item in
                    var entity = Entity.Model.toEntity(model: item)
                    try entity.upsert(db)
                }
            }
        } catch  {
            debugPrint("[GLMPDAO] Error inserting or replacing items: \(error)")
        }
    }
    
    @discardableResult
    open func getAll(completion: ((_ items: [Entity.Model]) -> Void)? = nil) -> LiveData<[Entity.Model]> {
        if completion != nil {
            do {
                try dbConfig.dbWriter.read { db in
                    let entities = try Entity.fetchAll(db)
                    let models = entities.compactMap { Entity.toModel(entity: $0) }
                    DispatchQueue.main.async {
                        completion?(models)
                    }
                }
            } catch {
                debugPrint("[GLMPDAO] getAll: \(error)")
            }
            
        }
        return allLiveData
    }
    
    open func getItem(_ id: String) async -> Entity.Model? {
        var resultModel: Entity.Model? = nil
        do {
            let item = try await dbConfig.dbWriter.read { db in
                var model: Entity.Model? = nil
                if let entity = try Entity.fetchOne(db, key: id) {
                    return Entity.toModel(entity: entity)
                }
                return model
            }
            resultModel = item
        } catch  {
            debugPrint("[GLMPDAO] getItem: \(error)")
        }
        return resultModel
    }
    
    open func deleteAll() {
        
        do {
            try dbConfig.dbWriter.write { db in
                try Entity.deleteAll(db)
            }
        } catch  {
            debugPrint("[GLMPDAO] Error deleting all items: \(error)")
        }
    }
    
    open func delete(_ items: [Entity.Model]) {
        
        
        do {
            try dbConfig.dbWriter.write { db in
                try items.forEach { item in
                    let entity = Entity.Model.toEntity(model: item)
                    try entity.delete(db)
                }
            }
        } catch  {
            debugPrint("[GLMPDAO] deleting items: \(error)")
        }
    }
}
