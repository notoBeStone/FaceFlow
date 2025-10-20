//
//  DBManager.swift
//  AppRepository
//
//  Created by user on 2024/5/10.
//

import Foundation
import GLDatabase
import AppModels
import CoreData
import GLMP
import GLCore
import GLConfig_Extension

public class DBManager {
    static let shared = DBManager()
    
    let dbConfig: GLMPDBConfiguration
    let dbName: String
    
    private static let defaultDBName: String = "coremodel"
    
    init() {
        self.dbName = Self.createFileName(Self.defaultDBName)
        self.dbConfig = GLMPDBConfiguration(fileName: dbName, migigrator: PTDatabaseMigrator())
    }
    
    private static func createFileName(_ name: String) -> String {
        var nameSuffix = ""
        if GL().GLConfig_currentEnvironmentIsProduction() {
            nameSuffix = "_prod"
        } else if GL().GLConfig_currentEnvironmentIsStage() {
            nameSuffix = "_stage"
        } else {
            nameSuffix = "_test"
        }
        return name + nameSuffix
    }
    
    public static func clearDababase() {
//        shared.diagnoseHistoryDao.deleteAll()
//        shared.historyItemDao.deleteAll()
//        shared.myPlantDao.deleteAll()
//        shared.myFolderDao.deleteAll()
//        shared.plantDao.deleteAll()
    }
    
//    lazy var plantDao: PlantDAO = {
//        return PlantDAO(dbConfig)
//    }()
//    
//    lazy var historyItemDao: SnapHistoryDAO = {
//        return SnapHistoryDAO(dbConfig)
//    }()
//    
//    public lazy var myPlantDao: MyPlantDAO = {
//        return MyPlantDAO(dbConfig)
//    }()
//    
//    public lazy var myFolderDao: MyFolderDAO = {
//       return MyFolderDAO(dbConfig)
//    }()
//    
//    public lazy var diagnoseHistoryDao: DiagnoseHistoryDAO = {
//       return DiagnoseHistoryDAO(dbConfig)
//    }()
}


fileprivate class PTDatabaseMigrator: GLMPDBMigrator {
    
    override init() {
        super.init()
        createTable()
        updateTable()
    }

    
    func createTable() {
        registerMigration("create_table") { db in
            //数据库表的创建顺序有要求，先创建独立表，再创建关联表。不然会crash
//            try PlantEntity.createTable(in: db)
//            try MyFolderEntity.createTable(in: db)
//            
//            try SnapHistoryEntity.createTable(in: db)
//            try MyPlantEntity.createTable(in: db)
//            try DiagnoseHistoryEntity.createTable(in: db)
        }
    }
    
    func updateTable() {
//        registerMigration("plant_add_itemId") { db in
//            try db.execute(sql: "ALTER TABLE \(PlantEntity.databaseTableName) ADD COLUMN \(PlantEntity.Columns.itemId.name) INTEGER")
//        }
    }
}
