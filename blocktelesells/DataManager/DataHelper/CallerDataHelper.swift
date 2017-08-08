//
//  CallerDataHelper.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 7/13/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import Foundation
import SQLite

class CallerDataHelper: DataHelperProtocol {
    

    var tableName = "Callers"
   
    var table: Table
    static let callerId = Expression<Int64>("callerId")
    static let callerNumber = Expression<String?>("callerNumber")
    static let countryCode = Expression<String?>("countryCode")
    static let registeredDate = Expression<Date?>("registeredDate")
    static let registeredByDevice = Expression<String?>("registeredByDevice")
    static let isLocal = Expression<Bool>("isLocal")
    static let isLocalBlocked = Expression<Bool>("isLocalBlocked")
    private init(){
        self.tableName = "Callers"
        self.table = Table(self.tableName)
    }
    init(tableName: String) {
        self.tableName = tableName
        self.table = Table(self.tableName)
    }
    public typealias T = Caller
   
    func createTable(DB: Connection) throws {
        
        do {
            try DB.run(table.create(ifNotExists: true) { table in
                table.column(CallerDataHelper.callerId, primaryKey: true)
                table.column(CallerDataHelper.callerNumber)
                table.column(CallerDataHelper.countryCode)
                table.column(CallerDataHelper.registeredDate)
                table.column(CallerDataHelper.registeredByDevice)
                table.column(CallerDataHelper.isLocal)
                table.column(CallerDataHelper.isLocalBlocked)
            })
           
        } catch  {
            print("Unable to create table")
        }
       
    }
    public func updateAll(items: [T]) throws -> Bool {
        var ret = false
        do{
            for item in items {
            try ret = update(cid:item.callerId!, updatedItem: item)
        }
        }catch{
            throw DataAccessError.Update_Error
        }
        return ret
        
    }
    public func update(cid:Int64, updatedItem: T) throws -> Bool {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do {
            
            let query = table.filter(CallerDataHelper.callerId == cid)
            let updated = query.update([
                        CallerDataHelper.callerNumber <- updatedItem.callerNumber!,
                        CallerDataHelper.countryCode <- updatedItem.countryCode!,
                        CallerDataHelper.registeredByDevice <- updatedItem.registeredByDevice,
                        CallerDataHelper.registeredDate <- updatedItem.registeredDate,
                        CallerDataHelper.isLocal <- updatedItem.isLocal,
                        CallerDataHelper.isLocalBlocked <- updatedItem.isLocalBlocked
                ])
             if try DB.run(updated) > 0 {
                return true
             }
            
        } catch {
            throw DataAccessError.Update_Error
        }
        throw DataAccessError.Nil_In_Data
    }
    public func insert(item: T) throws -> Int64 {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if (item.callerNumber != nil) {
            do{
                let existingCallers = try findByCallerNumber(callerNumber: item.callerNumber!)
                if existingCallers.count > 0 {
                    existingCallers[0].isLocal = true
                    if try update(cid: existingCallers[0].callerId!, updatedItem: existingCallers[0]){
                        return existingCallers[0].callerId!
                    }
                    
                }
                if try item.callerId == nil || ( find(id: item.callerId!)) == nil{
                    let rowId: Int64?
                    if item.callerId == nil {
                        let insert = table.insert(
                            CallerDataHelper.callerNumber <- item.callerNumber!,
                            CallerDataHelper.countryCode <- item.countryCode!,
                            CallerDataHelper.registeredByDevice <- item.registeredByDevice,
                            CallerDataHelper.registeredDate <- item.registeredDate,
                            CallerDataHelper.isLocal <- item.isLocal,
                            CallerDataHelper.isLocalBlocked <- item.isLocalBlocked
                        )
                        rowId = try DB.run(insert)
                    }else {
                        let insert = table.insert(
                            CallerDataHelper.callerId <- item.callerId!,
                            CallerDataHelper.callerNumber <- item.callerNumber!,
                            CallerDataHelper.countryCode <- item.countryCode!,
                            CallerDataHelper.registeredByDevice <- item.registeredByDevice,
                            CallerDataHelper.registeredDate <- item.registeredDate,
                            CallerDataHelper.isLocal <- item.isLocal,
                            CallerDataHelper.isLocalBlocked <- item.isLocalBlocked
                        )
                        rowId = try DB.run(insert)
                    }
                   
                    
                    guard rowId! > 0 else {
                        throw DataAccessError.Insert_Error
                    }
                    return rowId!
                }
                return item.callerId!
            }catch{
                throw DataAccessError.Insert_Error
            }
            
            
        }
        throw DataAccessError.Nil_In_Data
       
    }
    public func insertAll(items: [T]) throws -> [Int64] {
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
   
    public func delete (item: T) throws -> Void {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if let id = item.callerId {
            let query = table.filter(CallerDataHelper.callerId == id)
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
    public func deleteAll () throws -> Void {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do {
            try DB.run(table.delete())
        } catch _ {
            throw DataAccessError.Delete_Error
        }
    }
    public func find(id: Int64) throws -> T? {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(CallerDataHelper.callerId == id)
        do{
            let items = try DB.prepare(query)
            for item in  items {
                
                return try Caller.createCaller(
                    callerId: item[CallerDataHelper.callerId],
                    countryCode: item[CallerDataHelper.countryCode],
                    callerNumber: item[CallerDataHelper.callerNumber],
                    registeredByDevice: item[CallerDataHelper.registeredByDevice],
                    registeredDate: item[CallerDataHelper.registeredDate],
                    isLocal: item[CallerDataHelper.isLocal],
                    isLocalBlocked: item[CallerDataHelper.isLocalBlocked],
                    categories: LocalDataManager.sharedInstance.CALLER_CATEGORY_DATA_HELPER.findBy(callerId: item[CallerDataHelper.callerId])
                )
            }
        }catch {
            throw DataAccessError.Find_Error
        }
        return nil
       
    }
    public func findByCallerNumber(callerNumber: String) throws -> [T] {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var callers = [T]()
        let query = table.filter(CallerDataHelper.callerNumber == callerNumber)
        do{
            let items = try DB.prepare(query)
            for item in  items {
                
                let caller = try Caller.createCaller(
                    callerId: item[CallerDataHelper.callerId],
                    countryCode: item[CallerDataHelper.countryCode],
                    callerNumber: item[CallerDataHelper.callerNumber],
                    registeredByDevice: item[CallerDataHelper.registeredByDevice],
                    registeredDate: item[CallerDataHelper.registeredDate],
                    isLocal: item[CallerDataHelper.isLocal],
                    isLocalBlocked: item[CallerDataHelper.isLocalBlocked],
                    categories: LocalDataManager.sharedInstance.CALLER_CATEGORY_DATA_HELPER.findBy(callerId: item[CallerDataHelper.callerId])
                )
                callers.append(caller)
            }
        }catch {
            throw DataAccessError.Find_Error
        }
        return callers
       
    }
    public func findAllByLocal(isLocal: Bool) throws -> [T] {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var callers = [T]()
        let query = table.filter(CallerDataHelper.isLocal == isLocal)
        do{
            let items = try DB.prepare(query)
            for item in  items {
                
                let caller = try Caller.createCaller(
                    callerId: item[CallerDataHelper.callerId],
                    countryCode: item[CallerDataHelper.countryCode],
                    callerNumber: item[CallerDataHelper.callerNumber],
                    registeredByDevice: item[CallerDataHelper.registeredByDevice],
                    registeredDate: item[CallerDataHelper.registeredDate],
                    isLocal: item[CallerDataHelper.isLocal],
                    isLocalBlocked: item[CallerDataHelper.isLocalBlocked],
                    categories: LocalDataManager.sharedInstance.CALLER_CATEGORY_DATA_HELPER.findBy(callerId: item[CallerDataHelper.callerId])
                )
                callers.append(caller)
            }
        }catch {
            throw DataAccessError.Find_Error
        }
        return callers
       
    }
    public func findAllByLocalBlocked(isLocalBlocked: Bool) throws -> [T] {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var callers = [T]()
        let query = table.filter(CallerDataHelper.isLocalBlocked == isLocalBlocked)
        do{
            let items = try DB.prepare(query)
            for item in  items {
                let caller = try Caller.createCaller(
                    callerId: item[CallerDataHelper.callerId],
                    countryCode: item[CallerDataHelper.countryCode],
                    callerNumber: item[CallerDataHelper.callerNumber],
                    registeredByDevice: item[CallerDataHelper.registeredByDevice],
                    registeredDate: item[CallerDataHelper.registeredDate],
                    isLocal: item[CallerDataHelper.isLocal],
                    isLocalBlocked: item[CallerDataHelper.isLocalBlocked],
                    categories: LocalDataManager.sharedInstance.CALLER_CATEGORY_DATA_HELPER.findBy(callerId: item[CallerDataHelper.callerId])
                )
                callers.append(caller)
            }
        }catch {
            throw DataAccessError.Find_Error
        }
        return callers
       
    }
   
    public func findAll() throws -> [T]? {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var callers = [T]()
        do{
            let items = try DB.prepare(table)
            for item in items {
                
                let caller = try Caller.createCaller(
                    callerId: item[CallerDataHelper.callerId],
                    countryCode: item[CallerDataHelper.countryCode],
                    callerNumber: item[CallerDataHelper.callerNumber],
                    registeredByDevice: item[CallerDataHelper.registeredByDevice],
                    registeredDate: item[CallerDataHelper.registeredDate],
                    isLocal: item[CallerDataHelper.isLocal],
                    isLocalBlocked: item[CallerDataHelper.isLocalBlocked],
                    categories: LocalDataManager.sharedInstance.CALLER_CATEGORY_DATA_HELPER.findBy(callerId: item[CallerDataHelper.callerId]))
                callers.append(caller)
            }
        }catch{
            throw DataAccessError.FindAll_Error
        }
        
       
        return callers
       
    }
    func getCategoriesForCaller(categoryIds: String) throws -> [Category] {
        var categories = [Category]()
        do{
            for categoryId in (categoryIds.components(separatedBy: Caller.CATEGORY_ID_SEPARATOR)) {
                try categories.append(LocalDataManager.sharedInstance.CATEGORY_DATA_HELPER.find(id: Int64(categoryId)!)!)
            }
        }catch{
            throw DataAccessError.Find_Error
        }
        return categories
        
    }
    
}
