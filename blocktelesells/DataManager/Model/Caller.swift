//
//  Contact.swift
//  CallBlock
//
//  Created by Stephen Tran on 6/30/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import ObjectMapper
public class Caller: Mappable{
    public var callerId: Int64?
    public var countryCode: String?
    public var callerNumber: String?
    public var registeredDevice: String?
    public var registeredDate: Date?
    public var categories: [Category]?
    static let CATEGORY_ID_SEPARATOR = "_"
    static let CATEGORY_NAME_SEPARATOR = "\n"
    required public init?(map: Map) {
        
    }
    // Mappable
    public func mapping(map: Map) {
        callerId    <- map["callerId"]
        countryCode    <- map["country_code"]
        callerNumber    <- map["caller_number"]
        registeredDevice    <- map["registered_device"]
        categories    <- map["category"]
        registeredDate    <-  (map["registered_date"], DateTransform())
    }
    public func categoryIds() -> String{
        var s = ""
        for cat in categories! {
            if s.isEmpty {
                s += String(cat.categoryId!)
            } else {
                s += Caller.CATEGORY_ID_SEPARATOR + String(cat.categoryId!)
            }
            
        }
        return s
    }
    public func categoryNames() -> String{
        var s = ""
        for cat in categories! {
            s += String(cat.categoryName!) + Caller.CATEGORY_NAME_SEPARATOR
        }
        return s
    }
    public static func createCaller(callerId: Int64?, countryCode: String? ,callerNumber: String?, registeredDevice: String?, registeredDate: Date?, categories: [Category?]) -> Caller{
        
        let caller: Caller = Mapper<Caller>().map(JSON: [:])!
        caller.callerId = callerId
        caller.countryCode = countryCode
        caller.callerNumber = callerNumber
        caller.registeredDate = registeredDate
        caller.registeredDevice = registeredDevice
        caller.categories = categories as? [Category]
        
        return caller
        
    }

}
