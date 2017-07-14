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
        if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.stephentran.callblock") {
            let newDirectory = directory.appendingPathComponent("callers")
            try? fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: false, attributes: nil)
            do {
                BBDB = try Connection("\(newDirectory)/callblock.sqlite3")
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
        } catch {
            throw DataAccessError.Datastore_Connection_Error
        }
    }
}
