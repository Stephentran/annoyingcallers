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
    static func createTable(DB: Connection) throws -> Void
    static func insert(item: T) throws -> Int64
    static func delete(item: T) throws -> Void
    static func findAll() throws -> [T]?
}
