//
//  DataManager.swift
//  CallBlock
//
//  Created by Stephen Tran on 7/1/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

public final class DataManager {
    
    public static let CBX_IDENTIFIER = "com.ste.CallBlock.CallBlockExtension"
    public static let APP_GROUP_CALL_BLOCK_IDENTIFIER = "group.stephentran.callblock"
    public static let APP_GROUP_CALL_BLOCK_FOLDER = "callers"
    public static let APP_GROUP_CALL_BLOCK_SQLITE_FILE_NAME = "callblock.sqlite3"
    public static let COUNTRY_CODE_DEFAULT = "84"
    
    public static let sharedInstance = DataManager()
    public func getPhoneNumbers() -> [Int64: String] {
        var dictionary =  [Int64 : String]()
        do{
            let callers = try CallerDataHelper.findAll();
            for caller in callers! {
                var countryCode = DataManager.COUNTRY_CODE_DEFAULT
                if(caller.countryCode != nil && caller.countryCode!.range(of:"+") != nil ){
                    countryCode = caller.countryCode!
                    let range = countryCode.index(after: countryCode.startIndex)..<countryCode.endIndex
                    countryCode = countryCode[range]
                }
                let number = Int64(countryCode + String(describing: Int64(caller.callerNumber!)!))
                dictionary.updateValue(caller.categoryToString() , forKey:number!)
            }
        }catch{
            print("Unable to load phone numbers")
        }
        return dictionary
    }
}
