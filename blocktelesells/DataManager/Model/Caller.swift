//
//  Contact.swift
//  CallBlock
//
//  Created by Stephen Tran on 6/30/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import ObjectMapper
public class Caller: Mappable, Equatable{
    public var callerId: Int64?
    public var countryCode: String?
    public var callerNumber: String?
    public var registeredByDevice: String?
    public var registeredDate: Date?
    public var categories: [CallerCategory]?
    public var isLocal: Bool = false
    public var isLocalBlocked: Bool = false
    static let CATEGORY_ID_SEPARATOR = "_"
    static let CATEGORY_NAME_SEPARATOR = "-"
    public static let ASSIGN_TYPE_PRIVATE = 1
    public static let ASSIGN_TYPE_GLOBAL = 2
    public static let COUNTRY_CODE_VN = "+84"
    required public init?(map: Map) {
        
    }
    // Mappable
    public func mapping(map: Map) {
        callerId    <- map["id"]
        countryCode    <- map["country_code"]
        callerNumber    <- map["number"]
        registeredByDevice    <- map["registered_by_device"]
        registeredDate    <-  (map["registered_date"], DateTransform())
        categories    <- map["category"]
        if categories != nil {
            for category in categories! {
                category.callerId = callerId
            }
        }
        if callerNumber != nil {
            callerNumber = Caller.trimPrefixPhoneNumber(input: callerNumber!)
        }
        
    }
    public static func trimPrefixPhoneNumber(input: String) -> String{
        var result = input
        if input.hasPrefix("0"){
            let index = input.index(after: input.startIndex)
            result = input.substring(from: index)
        }
        if input.hasPrefix(Caller.COUNTRY_CODE_VN){
            let index = input.index(input.startIndex, offsetBy: 3)
            result = input.substring(from: index)
        }
        print("Phone Number " + result)
        return result
    }
    public func categoryIds() -> String{
        var s = ""
        if categories != nil {
            for cat in categories! {
                if s.isEmpty {
                    s += String(cat.categoryId!)
                } else {
                    s += Caller.CATEGORY_ID_SEPARATOR + String(cat.categoryId!)
                }
            
            }
        }
        
        return s
    }
    public func categoryNames() -> String{
        var s = ""
        for cat in categories! {
            if s == "" {
                s += String(cat.categoryName!)
            }else{
                s += Caller.CATEGORY_NAME_SEPARATOR + String(cat.categoryName!)
            }
            
        }
        return s
    }
    
    public static func createCaller(callerId: Int64?, countryCode: String? ,callerNumber: String?, registeredByDevice: String?, registeredDate: Date?, isLocal: Bool,isLocalBlocked: Bool, categories: [CallerCategory?]) -> Caller{
        
        let caller: Caller = Mapper<Caller>().map(JSON: [:])!
        
        if callerId != nil {
            caller.callerId = callerId!
        }
        
        caller.countryCode = countryCode
        caller.callerNumber = trimPrefixPhoneNumber(input: callerNumber!)
        caller.registeredDate = registeredDate
        caller.registeredByDevice = registeredByDevice
        caller.isLocal = isLocal
        caller.isLocalBlocked = isLocalBlocked
        caller.categories = categories as? [CallerCategory]
        return caller
        
    }
    public static func ==(lhs: Caller, rhs: Caller) -> Bool {
        return lhs.callerId ==  rhs.callerId
    }
    
}
