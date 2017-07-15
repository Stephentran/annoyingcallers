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
   
    private init() {
       
        let fileManager = FileManager.default
        if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: DataManager.APP_GROUP_CALL_BLOCK_IDENTIFIER) {
            let newDirectory = directory.appendingPathComponent(DataManager.APP_GROUP_CALL_BLOCK_FOLDER)
            try? fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: false, attributes: nil)
            do {
                BBDB = try Connection("\(newDirectory)/" + DataManager.APP_GROUP_CALL_BLOCK_SQLITE_FILE_NAME)
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
            try CallerDataHelper.createTable(DB: BBDB)
            try CategoryDataHelper.createTable(DB: BBDB)
        } catch {
            throw DataAccessError.Datastore_Connection_Error
        }
    }
}
