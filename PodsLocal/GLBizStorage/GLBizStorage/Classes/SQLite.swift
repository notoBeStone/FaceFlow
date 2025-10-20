//
//  SQLite.swift
//  GLBizStorage
//
//  Created by stephenwzl on 2024/12/9.
//

import GRDB


// 定义通用数据库表结构协议
public protocol GLBizStorageCommonSchema: Codable {
    var id: Int64? { get set }
    var userId: Int64 { get set }
    var bizType: String { get set }
    var data: String { get set }
    var createdAt: Date { get set }
    var updatedAt: Date { get set }
}

// 实现基础表结构
struct GLBizStorageRecord: GLBizStorageCommonSchema, FetchableRecord, PersistableRecord {
    var id: Int64?
    var userId: Int64
    var bizType: String
    var data: String
    var createdAt: Date
    var updatedAt: Date
    
    // 定义表名
    static var databaseTableName: String { "biz_storage" }
    
    // 数据库表初始化SQL
    static let createTableSQL = """
        CREATE TABLE IF NOT EXISTS \(databaseTableName) (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            biz_type TEXT NOT NULL CHECK(length(biz_type) <= 64),
            data TEXT NOT NULL CHECK(length(data) <= 65536),
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
        CREATE INDEX IF NOT EXISTS idx_user_biz ON \(databaseTableName)(user_id, biz_type);
    """
}

extension GLBizStorage {
    @GLBizStorageActor
    func setupDatabase() throws {
        try dbQueue?.write { db in
            try db.execute(sql: GLBizStorageRecord.createTableSQL)
        }
    }
    
    // 插入单条记录
    @GLBizStorageActor
    func insert(_ record: GLBizStorageRecord) throws {
        try dbQueue?.write { db in
            try record.insert(db)
        }
    }
    
    // 插入或更新记录（如果id已存在则更新）
    @GLBizStorageActor
    func save(_ record: GLBizStorageRecord) throws {
        try dbQueue?.write { db in
            try record.save(db)
        }
    }
    
    // 查询记录
    @GLBizStorageActor
    func fetchRecords(userId: Int64, bizType: String) throws -> [GLBizStorageRecord] {
        try dbQueue?.read { db in
            try GLBizStorageRecord
                .filter(Column("user_id") == userId && Column("biz_type") == bizType)
                .fetchAll(db)
        } ?? []
    }
    
    // 删除记录
    @GLBizStorageActor
    func deleteRecord(id: Int64) throws {
        try dbQueue?.write { db in
            try GLBizStorageRecord
                .filter(Column("id") == id)
                .deleteAll(db)
        }
    }
    
    // 更新记录
    @GLBizStorageActor
    func updateRecord(_ record: GLBizStorageRecord) throws {
        try dbQueue?.write { db in
            try record.update(db)
        }
    }
}
