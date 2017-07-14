//
//  DataAccessError.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 7/13/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

enum DataAccessError: Error {
    case Datastore_Connection_Error
    case Insert_Error
    case InsertAll_Error
    case Delete_Error
    case Update_Error
    case Find_Error
    case FindAll_Error
    case Search_Error
    case Nil_In_Data
}
