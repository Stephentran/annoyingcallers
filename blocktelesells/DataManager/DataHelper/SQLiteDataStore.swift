//
//  SQLiteDataStore.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 7/13/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import Foundation
import SQLite

class SQLiteDataStore {
    static let sharedInstance = SQLiteDataStore()
    var BBDB: Connection?
    var sqliteFileName = LocalDataManager.APP_GROUP_CALL_BLOCK_SQLITE_FILE_NAME
    public func configureSqliteFileName(sqliteFileName: String){
        self.sqliteFileName = sqliteFileName
    }
    private init() {
       
        let fileManager = FileManager.default
        if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: LocalDataManager.APP_GROUP_CALL_BLOCK_IDENTIFIER) {
            let newDirectory = directory.appendingPathComponent(LocalDataManager.APP_GROUP_CALL_BLOCK_FOLDER)
            try? fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: false, attributes: nil)
            do {
                BBDB = try Connection("\(newDirectory)/" + self.sqliteFileName)
            } catch {
                BBDB = nil
                print ("Unable to open database")
            }
            if BBDB != nil {
                do{
                    try createTables(BBDB: BBDB!)
                }catch {
                }
                
            }
        }else{
            print ("Unable to find group id")
            BBDB = nil
        }
    }
   
    func createTables(BBDB: Connection) throws{
        do {
            try LocalDataManager.sharedInstance.CALLER_DATA_HELPER.createTable(DB: BBDB)
            try LocalDataManager.sharedInstance.CATEGORY_DATA_HELPER.createTable(DB: BBDB)
            try LocalDataManager.sharedInstance.CALLER_CATEGORY_DATA_HELPER.createTable(DB: BBDB)
            
        } catch {
            throw DataAccessError.Datastore_Connection_Error
        }
    }
}
