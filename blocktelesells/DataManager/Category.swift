//
//  Category.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 7/15/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import ObjectMapper
public class Category: Mappable {
    public var categoryId: Int64?
    public var categoryName: String?
    public var description: String?
    public var createdDate: Date?
    required public init?(map: Map) {

    }
    // Mappable
    public func mapping(map: Map) {
        categoryId    <- map["id"]
        categoryName    <- map["name"]
        description    <- map["description"]
        createdDate    <- (map["created_date"], DateTransform())
        
    }
    public static func createCategory(categoryId: Int64?, categoryName: String? ,description: String?, createdDate: Date?) -> Category{
        let category: Category = Mapper<Category>().map(JSON: [:])!
        category.categoryId = categoryId
        category.categoryName = categoryName
        category.description = description
        category.createdDate = createdDate
        return category
        
    }
}
