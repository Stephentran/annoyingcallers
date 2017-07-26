//
//  DataManager.swift
//  CallBlock
//
//  Created by Stephen Tran on 7/1/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//
import SwiftyUserDefaults
import SwiftyJSON
import CallKit
import Reachability
extension DefaultsKeys {
    static let updatedStatus = DefaultsKey<Date?>("updatedStatus")
}
public final class LocalDataManager {
    
    public static let CBX_IDENTIFIER = "com.ste.CallBlock.CallBlockExtension"
    public static let APP_GROUP_CALL_BLOCK_IDENTIFIER = "group.stephentran.callblock"
    public static let APP_GROUP_CALL_BLOCK_FOLDER = "callers"
    public static let APP_GROUP_CALL_BLOCK_SQLITE_FILE_NAME = "callblock.sqlite3"
    public static let COUNTRY_CODE_DEFAULT = "84"
    let CALLER_DATA_HELPER = CallerDataHelper(tableName: "Callers")
    let CALLER_DATA_LOCAL_HELPER = CallerDataHelper(tableName: "LocalCallers")
    let BLOCKED_CALLER_DATA_HELPER = CallerDataHelper(tableName: "BlcokedCallers")
    let CATEGORY_DATA_HELPER = CategoryDataHelper(tableName: "Categories")
    
    public static let sharedInstance = LocalDataManager()
    public func getPhoneNumbers() -> [Int64: String] {
        var dictionary =  [Int64 : String]()
        do{
            let callers = try CALLER_DATA_HELPER.findAll();
            let blockedCallers = getBlockedPhoneNumbers();
            for caller in callers! {
                
                var countryCode = LocalDataManager.COUNTRY_CODE_DEFAULT
                if(caller.countryCode != nil && caller.countryCode!.range(of:"+") != nil ){
                    countryCode = caller.countryCode!
                    let range = countryCode.index(after: countryCode.startIndex)..<countryCode.endIndex
                    countryCode = countryCode[range]
                }
                let number = Int64(countryCode + String(describing: Int64(caller.callerNumber!)!))
                if blockedCallers[number!] != nil {
                    continue
                }
                dictionary.updateValue(caller.categoryNames() , forKey:number!)
            }
        }catch{
            print("Unable to load phone numbers")
        }
        return dictionary
    }
    
    public func getBlockedPhoneNumbers() -> [Int64: String] {
        var dictionary =  [Int64 : String]()
        do{
            let callers = try BLOCKED_CALLER_DATA_HELPER.findAll();
            for caller in callers! {
                var countryCode = LocalDataManager.COUNTRY_CODE_DEFAULT
                if(caller.countryCode != nil && caller.countryCode!.range(of:"+") != nil ){
                    countryCode = caller.countryCode!
                    let range = countryCode.index(after: countryCode.startIndex)..<countryCode.endIndex
                    countryCode = countryCode[range]
                }
                let number = Int64(countryCode + String(describing: Int64(caller.callerNumber!)!))
                dictionary.updateValue(caller.categoryNames() , forKey:number!)
            }
        }catch{
            print("Unable to load phone numbers")
        }
        return dictionary
    }
    public func saveUpdatedStatus(latestDate: Date){
        Defaults[.updatedStatus] = latestDate
    }
    public func loadUpdatedStatus() -> Date?{
        if Defaults[.updatedStatus] != nil {
            return Defaults[.updatedStatus]!
        }
        return nil
        
    }
    public func deleteAllLocalCaller(){
        do{
            try LocalDataManager.sharedInstance.CALLER_DATA_LOCAL_HELPER.deleteAll()
        }catch{
            print("Unable to delete all local callers")
        }
    }
    public func getLoadedCallers() -> [Caller]{
        var callers = [Caller]()
        do{
            let callers1 = try LocalDataManager.sharedInstance.CALLER_DATA_HELPER.findAll()!
            let callers2 = try LocalDataManager.sharedInstance.CALLER_DATA_LOCAL_HELPER.findAll()!
            callers += callers1
            callers += callers2
            
            return callers
        }catch{
            print("Get all Categories failed")
        }
        return [Caller]()
    }
    public func getLoadedCategories() -> [Category]{
        do{
            return try LocalDataManager.sharedInstance.CATEGORY_DATA_HELPER.findAll()!
        }catch{
            print("Get all Categories failed")
        }
        return [Category]()
    }
    /*
    // This insert method for saving new caller at local before submitting to server
    */
    public func insertCaller(caller: Caller) -> Bool{
        do{
            let id = try LocalDataManager.sharedInstance.CALLER_DATA_LOCAL_HELPER.insert(item: caller)
            self.reloadExtension()
            return id > 0
        }catch {
            print("Insert new Caller failed")
            return false
            
        }
    }
    public func insertBlockedCaller(caller: Caller) -> Bool{
        do{
            let id = try LocalDataManager.sharedInstance.BLOCKED_CALLER_DATA_HELPER.insert(item: caller)
            self.reloadExtension()
            return id > 0
        }catch {
            print("Insert new Caller failed")
            return false
            
        }
    }
    public func findOneBlockedCaller(callerId: Int64) -> Caller?{
        do{
            let caller = try LocalDataManager.sharedInstance.BLOCKED_CALLER_DATA_HELPER.find(id: callerId)
            return caller
        }catch {
            print("Find one Caller failed")
            
            
        }
        return nil
    }
    public func deleteBlockedCaller(caller: Caller?) -> Void{
        do{
            _ = try LocalDataManager.sharedInstance.BLOCKED_CALLER_DATA_HELPER.delete(item: caller!)
            self.reloadExtension()
        }catch {
            print("Delete  Caller failed")
            
            
        }
    }
    public func reloadExtension(){
        let callDirManager = CXCallDirectoryManager.sharedInstance;
        callDirManager.reloadExtension(withIdentifier: LocalDataManager.CBX_IDENTIFIER,
            completionHandler: {(error) in
            
                if (error == nil)
                {
                    print("Reloaded extension successfully")
                } else {
                    print("Reloaded extension failed with ")
                }
            
        })
    }
    public func findCallerBy(callerNumber: String) -> Caller? {
        do{
            return try LocalDataManager.sharedInstance.CALLER_DATA_HELPER.findBy(callerNumber: callerNumber)!
        }catch{
            print("Caller with number " + callerNumber + " not found")
        }
        return nil;
    }
    public func startDataRequest(callerUrl: String, categoryUrl: String, reachability: Reachability,allowCell: Bool, completionHandler: @escaping (_ result: Bool) -> Void){
    
        NetworkManager.sharedInstance.requestIfReachableViaWiFi(callerUrl: callerUrl, categoryUrl: categoryUrl, reachability: reachability,allowCell: allowCell, requestingHandler: syncUpCallers, completionHandler: completionHandler)
    }
    public func syncUpCallers(callerUrl: String, categoryUrl: String, completionHandler: @escaping (_ result: Bool) -> Void){
        DataService.sharedInstance.syncUpCallers(callerUrl: callerUrl, categoryUrl: categoryUrl, completionHandler:completionHandler)
    }
    
}
