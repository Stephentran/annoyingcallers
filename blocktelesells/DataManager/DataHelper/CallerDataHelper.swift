//
//  CallerDataHelper.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 7/13/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import Foundation
import SQLite

public class CallerDataHelper: DataHelperProtocol {
    static let TABLE_NAME = "Callers"
   
    static let table = Table(TABLE_NAME)
    static let callerId = Expression<Int64>("callerId")
    static let callerNumber = Expression<String?>("callerNumber")
    static let countryCode = Expression<String?>("countryCode")
    static let registeredDate = Expression<Date?>("registeredDate")
    static let registeredDevice = Expression<String?>("registeredDevice")
    static let category = Expression<String?>("category")
   
   
    public typealias T = Caller
   
    static func createTable(DB: Connection) throws {
        
        do {
            try DB.run(table.create(ifNotExists: true) { table in
                table.column(callerId, primaryKey: true)
                table.column(callerNumber, unique: true)
                table.column(countryCode)
                table.column(registeredDate)
                table.column(registeredDevice)
                table.column(category)
            })
           
        } catch  {
            print("Unable to create table")
        }
       
    }
    public static func update(cid:Int64, updatedItem: T) throws -> Bool {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do {
            let currentCaller = try find(id: cid)
            if(currentCaller != nil){
                let updated = table.update([
                        callerNumber <- updatedItem.callerNumber!,
                        countryCode <- updatedItem.countryCode!,
                        registeredDevice <- updatedItem.registeredDevice,
                        registeredDate <- updatedItem.registeredDate,
                        category <- updatedItem.categoryToString()
                ])
                if try DB.run(updated) > 0 {
                    return true
                }
            }
            
        } catch {
            throw DataAccessError.Update_Error
        }
        throw DataAccessError.Nil_In_Data
    }
    public static func insert(item: T) throws -> Int64 {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if (item.callerNumber != nil) {
            do{
                if (try find(id: item.callerId!)) == nil{
                   let insert = table.insert(
                        callerId <- item.callerId!,
                        callerNumber <- item.callerNumber!,
                        countryCode <- item.countryCode!,
                        registeredDevice <- item.registeredDevice,
                        registeredDate <- item.registeredDate,
                        category <- item.categoryToString()
                    )
                    let rowId = try DB.run(insert)
                    guard rowId > 0 else {
                        throw DataAccessError.Insert_Error
                    }
                    return rowId
                }
                return item.callerId!
            }catch{
                throw DataAccessError.Insert_Error
            }
            
            
        }
        throw DataAccessError.Nil_In_Data
       
    }
    public static func insertAll(items: [T]) throws -> [Int64] {
        var ret = [Int64]()
        do{
            for item in items {
            try ret.append(insert(item: item))
        }
        }catch{
            throw DataAccessError.Insert_Error
        }
        return ret
        
    }
   
    public static func delete (item: T) throws -> Void {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if let id = item.callerId {
            let query = table.filter(callerId == id)
            do {
                let tmp = try DB.run(query.delete())
                guard tmp == 1 else {
                    throw DataAccessError.Delete_Error
                }
            } catch _ {
                throw DataAccessError.Delete_Error
            }
        }
    }
   
    public static func find(id: Int64) throws -> T? {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(callerId == id)
        do{
            let items = try DB.prepare(query)
            for item in  items {
                return Caller.createCaller(
                    callerId: item[callerId],
                    countryCode: item[countryCode],
                    callerNumber: item[callerNumber],
                    registeredDevice: item[registeredDevice],
                    registeredDate: item[registeredDate],
                    category: item[category])
            }
        }catch {
            throw DataAccessError.Find_Error
        }
        return nil
       
    }
   
    public static func findAll() throws -> [T]? {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var callers = [T]()
        do{
            let items = try DB.prepare(table)
            for item in items {
                let caller = Caller.createCaller(
                    callerId: item[callerId],
                    countryCode: item[countryCode],
                    callerNumber: item[callerNumber],
                    registeredDevice: item[registeredDevice],
                    registeredDate: item[registeredDate],
                    category: item[category])
                    callers.append(caller)
            }
        }catch{
            throw DataAccessError.FindAll_Error
        }
        
       
        return callers
       
    }
    
}
