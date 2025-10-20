//
//  GLMPDBConfiguration.swift
//  CoreDataDemo
//
//  Created by xie.longyan on 2024/6/6.
//

import Foundation
import GRDB
import GLUtils

let GLMPDBDir = "com.glmpdb.default"

public class GLMPDBConfiguration {
    
    public let dbWriter: any DatabaseWriter
    
    public init(fileName: String, migigrator: GLMPDBMigrator) {
        do {
            let url = try Self.getDBFileURL(name: fileName)
            debugPrint("db path => \(url.path)")
            var config = Configuration()
            #if DEBUG
            config.publicStatementArguments = true
            #endif
            
            let dbPool = try DatabasePool(path: url.path, configuration: config)
            self.dbWriter = dbPool
            try migigrator.migrate(dbPool)
        } catch  {
            fatalError("Unresolved error \(error)")
        }
    }
    
}


extension GLMPDBConfiguration {
    
    public static func getDBFileURL(name: String) throws -> URL {
        let suffix = ".sqlite"
        let filename = name.hasSuffix(suffix) ? name : "\(name)\(suffix)"
        let fileManager = FileManager.default
        let documentDirectoryURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let dbDirectoryURL = documentDirectoryURL.appendingPathComponent(GLMPDBDir)
        
        if !fileManager.fileExists(atPath: dbDirectoryURL.path) {
            try fileManager.createDirectory(at: dbDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        return dbDirectoryURL.appendingPathComponent(filename)
    }
}
