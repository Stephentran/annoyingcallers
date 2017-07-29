//
//  CategoryDataHelper.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 7/15/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import Foundation
import SQLite

class CategoryDataHelper: DataHelperProtocol {
    var tableName = "Categories"
   
    let table: Table
    static let categoryId = Expression<Int64>("categoryId")
    static let categoryName = Expression<String?>("categoryName")
    static let description = Expression<String?>("description")
    static let createdDate = Expression<Date?>("createdDate")
    public typealias T = Category
    private init(){
        self.tableName = "Categories"
        self.table = Table(self.tableName)
    }
    init(tableName: String) {
        self.tableName = tableName
        self.table = Table(self.tableName)
    }
    func createTable(DB: Connection) throws {
        
        do {
            try DB.run(table.create(ifNotExists: true) { table in
                table.column(CategoryDataHelper.categoryId, primaryKey: true)
                table.column(CategoryDataHelper.categoryName)
                table.column(CategoryDataHelper.description)
                table.column(CategoryDataHelper.createdDate)
            })
           
        } catch  {
            print("Unable to create table")
        }
       
    }
    public func delete(item: T) throws -> Void{
    }
    public func updateAll(items: [T]) throws -> Bool {
        var ret = false
        do{
            for item in items {
            try ret = update(cid:item.categoryId!, updatedItem: item)
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
            
            let query = table.filter(CategoryDataHelper.categoryId == cid)
            let updated = query.update([
                        CategoryDataHelper.categoryName <- updatedItem.categoryName!,
                        CategoryDataHelper.description <- updatedItem.description!,
                        CategoryDataHelper.createdDate <- updatedItem.createdDate
                ])
             if try DB.run(updated) > 0 {
                return true
             }
            
        } catch {
            throw DataAccessError.Update_Error
        }
        throw DataAccessError.Nil_In_Data
    }
    public func findAll() throws -> [T]?{
        var categories = [T]()
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do{
            let items = try DB.prepare(table)
            for item in items {
                let caller = Category.createCategory(
                    categoryId: item[CategoryDataHelper.categoryId],
                    categoryName: item[CategoryDataHelper.categoryName],
                    description: item[CategoryDataHelper.description],
                    createdDate: item[CategoryDataHelper.createdDate])
                categories.append(caller)
            }
        }catch{
            throw DataAccessError.FindAll_Error
        }
        
       
        return categories
    }
    public func find(id: Int64) throws -> T? {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(CategoryDataHelper.categoryId == id)
        do{
            let items = try DB.prepare(query)
            for item in  items {
                return Category.createCategory(
                    categoryId: item[CategoryDataHelper.categoryId],
                    categoryName: item[CategoryDataHelper.categoryName],
                    description: item[CategoryDataHelper.description],
                    createdDate: item[CategoryDataHelper.createdDate])
            }
        }catch {
            throw DataAccessError.Find_Error
        }
        return nil
       
    }
    public func insert(item: T) throws -> Int64 {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do{
            if (try find(id: item.categoryId!)) == nil{
                let insert = table.insert(
                        CategoryDataHelper.categoryId <- item.categoryId!,
                        CategoryDataHelper.categoryName <- item.categoryName!,
                        CategoryDataHelper.description <- item.description!,
                        CategoryDataHelper.createdDate <- item.createdDate
                    )
                let rowId = try DB.run(insert)
                guard rowId > 0 else {
                    throw DataAccessError.Insert_Error
                }
                return rowId
            }
            return item.categoryId!
            
        }catch{
            throw DataAccessError.Insert_Error
        }
       
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
}
