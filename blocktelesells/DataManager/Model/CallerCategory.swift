//
//  CallerCategory.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 7/27/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import ObjectMapper

public class CallerCategory: Mappable, Equatable {
    public var id: Int64?
    public var callerId: Int64?
    public var categoryId: Int64?
    public var assignType: Int?
    public var assignedDate: Date?
    public var categoryName: String?
    public var isLocal: Bool = false
    
    required public init?(map: Map) {

    }
    // Mappable
    public func mapping(map: Map) {
        id    <- map["id"]
        callerId    <- map["callerId"]
        categoryId    <- map["id"]
        assignType    <- map["assign_type"]
        assignedDate    <- (map["assigned_date"], DateTransform())
        categoryName    <- map["name"]
    }
    public static func createCallerCategory(id: Int64?,callerId: Int64?, categoryId: Int64? ,assignType: Int?, assignedDate: Date?, isLocal: Bool, categoryName: String?) -> CallerCategory{
        let calleCategory: CallerCategory = Mapper<CallerCategory>().map(JSON: [:])!
        calleCategory.id = id
        if callerId != nil {
            calleCategory.callerId = callerId
        }
        
        calleCategory.categoryId = categoryId
        calleCategory.assignType = assignType
        calleCategory.assignedDate = assignedDate
        calleCategory.categoryName = categoryName
        calleCategory.isLocal = isLocal
        return calleCategory
    }
    public static func ==(lhs: CallerCategory, rhs: CallerCategory) -> Bool {
        return lhs.categoryId ==  rhs.categoryId && lhs.callerId ==  rhs.callerId
    }
}
