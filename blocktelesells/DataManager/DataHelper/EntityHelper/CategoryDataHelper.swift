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
    static let TABLE_NAME = "Categories"
   
    static let table = Table(TABLE_NAME)
    static let categoryId = Expression<Int64>("categoryId")
    static let categoryName = Expression<String?>("categoryName")
    static let categoryType = Expression<Int?>("categoryType")
    static let createdDate = Expression<Date?>("createdDate")
    public typealias T = Category
   
    static func createTable(DB: Connection) throws {
        
        do {
            try DB.run(table.create(ifNotExists: true) { table in
                table.column(categoryId, primaryKey: true)
                table.column(categoryName)
                table.column(categoryType)
                table.column(createdDate)
            })
           
        } catch  {
            print("Unable to create table")
        }
       
    }
    public static func delete(item: T) throws -> Void{
    }
    public static func update(cid:Int64, updatedItem: T) throws -> Bool{
        return false;
    }
    public static func findAll() throws -> [T]?{
        var categories = [T]()
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do{
            let items = try DB.prepare(table)
            for item in items {
                let caller = Category.createCategory(
                    categoryId: item[categoryId],
                    categoryName: item[categoryName],
                    categoryType: item[categoryType],
                    createdDate: item[createdDate])
                categories.append(caller)
            }
        }catch{
            throw DataAccessError.FindAll_Error
        }
        
       
        return categories
    }
    public static func find(id: Int64) throws -> T? {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(categoryId == id)
        do{
            let items = try DB.prepare(query)
            for item in  items {
                return Category.createCategory(
                    categoryId: item[categoryId],
                    categoryName: item[categoryName],
                    categoryType: item[categoryType],
                    createdDate: item[createdDate])
            }
        }catch {
            throw DataAccessError.Find_Error
        }
        return nil
       
    }
    public static func insert(item: T) throws -> Int64 {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do{
            if (try find(id: item.categoryId!)) == nil{
                let insert = table.insert(
                        categoryId <- item.categoryId!,
                        categoryName <- item.categoryName!,
                        categoryType <- item.categoryType!,
                        createdDate <- item.createdDate
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
}
