//
//  GLMPDBMigrator.swift
//  AppRepository
//
//  Created by user on 2024/9/23.
//

import Foundation
import GRDB
open class GLMPDBMigrator {
    
    
    lazy var migrator = DatabaseMigrator()
    
    public init() {
        
    }
    
    public func registerMigration(_ identifier: String, 
                                  foreignKeyChecks: DatabaseMigrator.ForeignKeyChecks = .deferred,
                                  migrate: @escaping (Database) throws -> Void) {
        migrator.registerMigration(identifier, foreignKeyChecks: foreignKeyChecks, migrate: migrate)
    }
    
    
    public func migrate(_ writer: some DatabaseWriter) throws {
        try migrator.migrate(writer)
    }
    
}
