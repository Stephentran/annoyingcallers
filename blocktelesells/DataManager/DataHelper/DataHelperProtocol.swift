//
//  DataHelperProtocol.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 7/13/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//
import SQLite
protocol DataHelperProtocol {
    associatedtype T
    func createTable(DB: Connection) throws -> Void
    func insert(item: T) throws -> Int64
    func delete(item: T) throws -> Void
    func update(cid:Int64, updatedItem: T) throws -> Bool
    func findAll() throws -> [T]?
}
