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
    public var category: [String]?
    required public init?(map: Map) {

    }
    // Mappable
    public func mapping(map: Map) {
        callerId    <- map["callerId"]
        countryCode    <- map["country_code"]
        callerNumber    <- map["caller_number"]
        registeredDevice    <- map["registered_device"]
        category    <- map["category"]
        registeredDate    <-  (map["registered_date"], DateTransform())
    }
    public func categoryToString() -> String{
        var s = ""
        for cat in category! {
            s += cat + "\n"
        }
        return s
    }
    public static func createCaller(callerId: Int64?, countryCode: String? ,callerNumber: String?, registeredDevice: String?, registeredDate: Date?, category: String?) -> Caller{
        let caller: Caller = Mapper<Caller>().map(JSON: [:])!
        caller.callerId = callerId
        caller.countryCode = countryCode
        caller.callerNumber = callerNumber
        caller.registeredDate = registeredDate
        caller.registeredDevice = registeredDevice
        caller.category = category?.components(separatedBy: "\n")
        return caller
        
    }

}
