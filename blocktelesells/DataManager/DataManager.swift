//
//  DataManager.swift
//  CallBlock
//
//  Created by Stephen Tran on 7/1/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

public final class DataManager {
    public static let sharedInstance = DataManager()
    
    public func getPhoneNumbers() -> [Int64: String] {
        var dictionary =  [Int64 : String]()
        do{
            let callers = try CallerDataHelper.findAll();
            for caller in callers! {
                let number = Int64("84" + String(describing: Int64(caller.callerNumber!)!))
                dictionary.updateValue(caller.categoryToString() , forKey:number!)
            }
        }catch{
            print("Unable to load phone numbers")
        }
        return dictionary
    }
}
