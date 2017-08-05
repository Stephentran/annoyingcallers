//
//  Device.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 8/4/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import ObjectMapper

class Device: Mappable {
    public var id: String?
    public var platform: String?
    public var owner: String?
    public var status: Int
    public var api_request_key: String?
    
    required public init?(map: Map) {
        status = 1
        platform = LocalDataManager.PLATFORM
        id = UIDevice.current.identifierForVendor!.uuidString
    }
    
    // Mappable
    public func mapping(map: Map) {
        id    <- map["id"]
        platform    <- map["platform"]
        owner    <- map["owner"]
        status    <- map["status"]
        api_request_key    <- map["api_request_key"]
        
    }
    public static func createDevice(id: String, platform: String? ,owner: String?, status: Int, api_request_key: String?) -> Device{
        
        let device: Device = Mapper<Device>().map(JSON: [:])!
        
        device.id = id
        
        device.platform = platform
        device.owner = owner
        device.status = status
        device.api_request_key = api_request_key
        return device
        
    }
}
