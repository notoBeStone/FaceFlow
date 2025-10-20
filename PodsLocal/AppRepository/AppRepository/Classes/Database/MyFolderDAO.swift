//
//  MyFolderDAO.swift
//  AppRepository
//
//  Created by user on 2024/6/3.
//

import Foundation
import GLMP
import AppModels
import DGMessageAPI
import GLUtils
import GRDB

// 数据库操作

//public class MyFolderDAO: GLMPDAO<MyFolderEntity> {
//    
//    
//    func findMyFolderWithMyPlantListAppModel(_ folderId: Int64) -> GLMPDBLiveData<MyFolderWithMyPlantListAppModel> {
//    
//        let ob = GLMPDBLiveData<MyFolderWithMyPlantListAppModel>(dbWriter: dbConfig.dbWriter) { db in
//            let result = try MyFolderEntity.including(all: MyFolderEntity.myPlantsEntity.including(required: MyPlantEntity.plantEntity)).filter(MyFolderEntity.Columns.myFolderId == folderId).asRequest(of: MyFolderPlantsEntity.self).fetchOne(db)
//            return result
//        }
//        return ob
//    }
//    
//    
//    func getMyFolderWithMyPlantList() -> GLMPDBLiveData<[MyFolderWithMyPlantListAppModel]> {
//        
//        let ob = GLMPDBLiveData<[MyFolderWithMyPlantListAppModel]>(dbWriter: dbConfig.dbWriter) { db in
//            let result = try MyFolderEntity.including(all: MyFolderEntity.myPlantsEntity.including(required: MyPlantEntity.plantEntity)).asRequest(of: MyFolderPlantsEntity.self).order(MyFolderEntity.Columns.myFolderId.desc).fetchAll(db)
//            return result
//        }
//        return ob
//    }
//}
//
//public final class MyFolderEntity: GLMPDAOEntity {
//   
//    
//    public typealias Model = MyFolderAppModel
//    
//    var myFolderId: Int64
//    
//    var name: String
//    
//    var createAt: Date
//    
//    var areaType: Int
//    
//    
//    public var id: String { String(myFolderId) }
//    
//    init() {
//        self.myFolderId = 0
//        self.name = ""
//        self.createAt = Date()
//        self.areaType = 0
//    }
//    //Table name
//    static public var databaseTableName: String {
//        return "folders"
//    }
//    
//    // Table Colums
//    fileprivate enum Columns {
//        static let myFolderId = Column("myFolderId")
//        static let name = Column("name")
//        static let createAt = Column("createAt")
//        static let areaType = Column("areaType")
//    }
//    
//    // create table
//    public static func createTable(in db: GRDB.Database) throws {
//        try db.create(table: Self.databaseTableName) { t in
//            t.column(Columns.myFolderId.name, .integer).primaryKey()
//            t.column(Columns.name.name, .text).notNull()
//            t.column(Columns.createAt.name, .date).notNull()
//            t.column(Columns.areaType.name, .integer).notNull()
//        }
//    }
//    
//    static let myPlantsEntity = hasMany(MyPlantEntity.self)
////    static let plantsEntity = hasMany(PlantEntity.self, through: myPlantsEntity, using: MyPlantEntity.plantEntity)
//    
////    //MARK: - GRDB encode
////    public func encode(to container: inout PersistenceContainer) throws {
////        container["myFolderId"] = myFolderId
////        container["name"] = name
////        container["createAt"] = createAt
////        container["areaType"] = areaType
////    }
////    
////    //MARK: - GRDB decode
////    public init(row: Row) throws {
////        self.myFolderId = row["myFolderId"]
////        self.name = row["name"]
////        self.createAt = row["createAt"]
////        self.areaType = row["areaType"]
////    }
//    
//    public static func toModel(entity: MyFolderEntity) -> MyFolderAppModel? {
//        guard let areaType = FolderAreaType(rawValue: Int(entity.areaType)) else {
//            return nil
//        }
//        return MyFolderAppModel(myFolderId: entity.myFolderId,
//                                name: entity.name,
//                                createAt: entity.createAt,
//                                areaType: areaType)
//    }
//}
//
//
//extension MyFolderAppModel: GLMPDAOModel {
//    
//    public typealias Entity = MyFolderEntity
//    
//    public static func toEntity(model: AppModels.MyFolderAppModel) -> MyFolderEntity {
//        let entity = MyFolderEntity()
//        entity.myFolderId = model.myFolderId
//        entity.name = model.name
//        entity.createAt = model.createAt
//        entity.areaType = Int(model.areaType.rawValue)
//        return entity
//    }
//    
//}
