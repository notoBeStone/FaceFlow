//
//  GLDBObservation.swift
//  GLMP
//
//  Created by user on 2024/9/25.
//

import Foundation
import GRDB
import GLUtils



// MARK: - Model
public protocol GLMPDBLiveDataModel {
    /// 指定关联的 Entity
    associatedtype Entity: GLMPDBLiveDataEntity
    
    /// Model to Entity
    static func toEntity(model: Self) -> Entity
}

// MARK: - Entity
public protocol GLMPDBLiveDataEntity: Codable {
    /// 指定关联的 Model
    associatedtype Model: GLMPDBLiveDataModel
    /// Entity to Model
    static func toModel(entity: Self) -> Model?
}


extension Array: GLMPDBLiveDataModel where Element: GLMPDBLiveDataModel {
    public typealias Entity = [Element.Entity]
    
    public static func toEntity(model: Self) -> [Element.Entity] {
        return model.compactMap { Element.toEntity(model: $0) }
    }
}

extension Array: GLMPDBLiveDataEntity where Element: GLMPDBLiveDataEntity {
    public typealias Model = [Element.Model]
    
    public static func toModel(entity: Self) -> [Element.Model]? {
        return entity.compactMap { Element.toModel(entity: $0) }
    }
}


public class GLMPDBLiveData<T: GLMPDBLiveDataModel> {
    
    private var liveData: LiveData<T> = LiveData()
    
    private var cancellable: DatabaseCancellable?
    
    public init(dbWriter: any DatabaseWriter, tracking: @escaping (Database) throws -> T.Entity?) {
        observation(dbWriter, tracking: tracking)
    }
    
    deinit {
        cancellable?.cancel()
        cancellable = nil
    }
    
    private func observation(_ dbWriter: any DatabaseWriter, tracking: @escaping (Database) throws -> T.Entity?) {
        var observation = ValueObservation.tracking { db in
            try tracking(db)
        }
        
        cancellable = observation.start(in: dbWriter) { error in
            debugPrint("GLMPDBLiveData error: \(error)")
        } onChange: { [weak self] changes in
            if let changes = changes, let model = T.Entity.toModel(entity: changes) as? T {
                self?.liveData.value = model
            } else {
                self?.liveData.value = nil
            }
        }
    }
    
    public func observe(_ immediate: Bool = false, listener: @escaping ((T?) -> Void)) -> LiveDataToken<T> {
        return liveData.observe(immediate, listener: listener)
    }
    
    public func getValue() -> T? {
        return liveData.value
    }
}
