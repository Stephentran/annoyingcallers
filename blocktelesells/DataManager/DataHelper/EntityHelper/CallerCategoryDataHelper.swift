//
//  CallerCategoryDataHelper.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 7/27/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import Foundation
import SQLite

class CallerCategoryDataHelper: DataHelperProtocol {
    var tableName = "CallerCategories"
   
    var table: Table
    var callerTable: Table
    var categoryTable: Table
    static let id = Expression<Int64>("id")
    static let callerId = Expression<Int64>("callerId")
    static let categoryId = Expression<Int64>("categoryId")
    static let assignType = Expression<Int>("assignType")
    static let assignedDate = Expression<Date?>("assignedDate")
    static let categoryName = Expression<String?>("categoryName")
    static let isLocal = Expression<Bool>("isLocal")
    
    
    
    private init(){
        self.tableName = "CallerCategories"
        self.table = Table(self.tableName)
        self.callerTable = Table("Callers")
        self.categoryTable = Table("Categories")
    }
    init(tableName: String) {
        self.tableName = tableName
        self.table = Table(self.tableName)
        self.callerTable = Table("Callers")
        self.categoryTable = Table("Categories")
    }
    public typealias T = CallerCategory
   
    func createTable(DB: Connection) throws {
        
        do {
            try DB.run(table.create(ifNotExists: true) { table in
                
                table.column(CallerCategoryDataHelper.id, primaryKey: true)
                //table.foreignKey(CallerCategoryDataHelper.callerId, references: callerTable,CallerCategoryDataHelper.callerId, update: .setNull, delete: .setNull)
                //table.foreignKey(CallerCategoryDataHelper.categoryId, references: categoryTable,CallerCategoryDataHelper.categoryId, update: .setNull, delete: .setNull)
                table.column(CallerCategoryDataHelper.callerId)
                table.column(CallerCategoryDataHelper.categoryId)
                table.column(CallerCategoryDataHelper.assignType)
                table.column(CallerCategoryDataHelper.assignedDate)
                table.column(CallerCategoryDataHelper.categoryName)
                table.column(CallerCategoryDataHelper.isLocal)
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
            
            let query = table.filter(CallerCategoryDataHelper.callerId == cid)
            let updated = query.update([
                        CallerCategoryDataHelper.callerId <- updatedItem.callerId!,
                        CallerCategoryDataHelper.categoryId <- updatedItem.categoryId!,
                        CallerCategoryDataHelper.assignType <- updatedItem.assignType!,
                        CallerCategoryDataHelper.categoryName <- updatedItem.categoryName,
                        CallerCategoryDataHelper.isLocal <- updatedItem.isLocal
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
        if (item.categoryId != nil && item.assignType != nil) {
            do{
                
                if try item.id == nil || ( find(id: item.id!)) == nil{
                    let rowId: Int64?
                    let insert = table.insert(
                            CallerCategoryDataHelper.callerId <- item.callerId!,
                            CallerCategoryDataHelper.categoryId <- item.categoryId!,
                            CallerCategoryDataHelper.assignType <- item.assignType!,
                            CallerCategoryDataHelper.assignedDate <- item.assignedDate,
                            CallerCategoryDataHelper.categoryName <- item.categoryName,
                            CallerCategoryDataHelper.isLocal <- item.isLocal
                        )
                        rowId = try DB.run(insert)
                    
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
            item.id = nil
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
            let query = table.filter(CallerCategoryDataHelper.callerId == id)
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
        let query = table.filter(CallerCategoryDataHelper.callerId == id)
        do{
            let items = try DB.prepare(query)
            for item in  items {
                
                return T.createCallerCategory(
                    id: item[CallerCategoryDataHelper.id],
                    callerId: item[CallerCategoryDataHelper.callerId],
                    categoryId: item[CallerCategoryDataHelper.categoryId],
                    assignType: item[CallerCategoryDataHelper.assignType],
                    assignedDate: item[CallerCategoryDataHelper.assignedDate],
                    isLocal: item[CallerCategoryDataHelper.isLocal],
                    categoryName: item[CallerCategoryDataHelper.categoryName]
                )
            }
        }catch {
            throw DataAccessError.Find_Error
        }
        return nil
       
    }
    public func findBy(callerId: Int64) throws -> [T] {
        var result = [T]()
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(CallerCategoryDataHelper.callerId == callerId)
        do{
            let items = try DB.prepare(query)
            for item in  items {
                
                let callerCategory = T.createCallerCategory(
                    id: item[CallerCategoryDataHelper.id],
                    callerId: item[CallerCategoryDataHelper.callerId],
                    categoryId: item[CallerCategoryDataHelper.categoryId],
                    assignType: item[CallerCategoryDataHelper.assignType],
                    assignedDate: item[CallerCategoryDataHelper.assignedDate],
                    isLocal: item[CallerCategoryDataHelper.isLocal],
                    categoryName: item[CallerCategoryDataHelper.categoryName]
                )
                result.append(callerCategory)
            }
        }catch {
            throw DataAccessError.Find_Error
        }
        return result
       
    }
   
    public func findAll() throws -> [T]? {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var callerCategoies = [T]()
        do{
            let items = try DB.prepare(table)
            for item in items {
                
                let callerCategory = T.createCallerCategory(
                    id: item[CallerCategoryDataHelper.id],
                    callerId: item[CallerCategoryDataHelper.callerId],
                    categoryId: item[CallerCategoryDataHelper.categoryId],
                    assignType: item[CallerCategoryDataHelper.assignType],
                    assignedDate: item[CallerCategoryDataHelper.assignedDate],
                    isLocal: item[CallerCategoryDataHelper.isLocal],
                    categoryName: item[CallerCategoryDataHelper.categoryName]
                )
                callerCategoies.append(callerCategory)
            }
        }catch{
            throw DataAccessError.FindAll_Error
        }
        
       
        return callerCategoies
       
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
