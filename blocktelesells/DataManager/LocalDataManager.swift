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
import MMWormhole
extension DefaultsKeys {
    static let updatedStatus = DefaultsKey<Date?>("updatedStatus")
    static let keytToken = DefaultsKey<String?>("keyToken")
    static let autoUpdate = DefaultsKey<Bool?>("autoUpdate")
    static let copiedPhoneNumber = DefaultsKey<String?>("copiedPhoneNumber")
}
public final class LocalDataManager {
    public static let SERVICE_URL = "http://103.48.191.84:8000/api/"
    public static let SERVICE_CALLER_URL = SERVICE_URL + "callers/"
    public static let SERVICE_CATEGORY_URL = SERVICE_URL + "categories"
    public static let SERVICE_TOKEN_URL = SERVICE_URL + "devices/"
    public static let CBX_IDENTIFIER = "com.hungduong.phien.BTSExtension"
    public static let APP_GROUP_CALL_BLOCK_IDENTIFIER = "group.hungduong.phien"
    public static let APP_GROUP_CALL_BLOCK_FOLDER = "callers"
    public static let APP_GROUP_CALL_BLOCK_SQLITE_FILE_NAME = "callblock.sqlite3"
    public static let COUNTRY_CODE_DEFAULT = "84"
    public static let  API_REQUEST_KEY = "API-REQUEST-KEY"
    public static let  PLATFORM = "iOS"
    public static let wormhole = MMWormhole(applicationGroupIdentifier: APP_GROUP_CALL_BLOCK_IDENTIFIER, optionalDirectory: "blockcall")
    let CALLER_DATA_HELPER = CallerDataHelper(tableName: "Callers")
    let CATEGORY_DATA_HELPER = CategoryDataHelper(tableName: "Categories")
    let CALLER_CATEGORY_DATA_HELPER = CallerCategoryDataHelper(tableName: "CallerCategories")
    
    public static let sharedInstance = LocalDataManager()
    public func getPhoneNumbers() -> [Int64: String] {
        do{
            var callers = [Caller]()
            if LocalDataManager.sharedInstance.loadBlockCall() == false {
                callers = try CALLER_DATA_HELPER.findAll()!
            }
            
            return formatPhoneNumber(callers: callers)
        }catch{
            print("Unable to load phone numbers")
        }
        return [Int64 : String]()
    }
    
    public func getBlockedPhoneNumbers() -> [Int64: String] {
        
        do{
            var callers = [Caller]()
            if LocalDataManager.sharedInstance.loadBlockCall() == true {
                callers += try CALLER_DATA_HELPER.findAll()!
            }
            return formatPhoneNumber(callers: callers)
        }catch{
            print("Unable to load phone numbers")
        }
        return [Int64 : String]()
    }
    func formatPhoneNumber(callers: [Caller])  -> [Int64: String]{
        var dictionary =  [Int64 : String]()
        for caller in callers {
            var countryCode = LocalDataManager.COUNTRY_CODE_DEFAULT
            if(caller.countryCode != nil && caller.countryCode!.range(of:"+") != nil ){
                countryCode = caller.countryCode!
                let range = countryCode.index(after: countryCode.startIndex)..<countryCode.endIndex
                countryCode = countryCode[range]
            }
            let number = Int64(countryCode + String(describing: Int64(caller.callerNumber!.replacingOccurrences(of: " ", with: ""))!))
            dictionary.updateValue(caller.categoryNames() , forKey:number!)
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
    
    public func saveKeytToken(keytToken: String){
        Defaults[.keytToken] = keytToken
    }
    public func loadKeytToken() -> String?{
        if Defaults[.keytToken] != nil {
            return Defaults[.keytToken]!
        }
        return nil
    }
    public func saveCopiedPhoneNumber(copiedPhoneNumber: String){
        LocalDataManager.wormhole.passMessageObject(copiedPhoneNumber as NSCoding, identifier: "copiedPhoneNumber")
    }
    public func clearCopiedPhoneNumber(){
        LocalDataManager.wormhole.clearMessageContents(forIdentifier: "copiedPhoneNumber")
    }
    public func loadCopiedPhoneNumber() -> String?{
        let obj = LocalDataManager.wormhole.message(withIdentifier: "copiedPhoneNumber")
        if obj != nil {
            return obj as? String
        }
        return nil
    }
    
    public func saveComeFromActionExtensionFlag(comeFromActionExtensionFlag: Bool){
        LocalDataManager.wormhole.passMessageObject(comeFromActionExtensionFlag as NSCoding, identifier: "comeFromActionExtensionFlag")
    }
    public func loadComeFromActionExtensionFlag() -> Bool?{
        let obj = LocalDataManager.wormhole.message(withIdentifier: "comeFromActionExtensionFlag")
        if obj != nil {
            return obj as? Bool
        }
        return nil
    }
    public func saveBlockCall(blockCall: Bool){
        LocalDataManager.wormhole.passMessageObject(blockCall as NSCoding, identifier: "allowBlockFlag")
    }
    public func loadBlockCall() -> Bool?{
        let obj = LocalDataManager.wormhole.message(withIdentifier: "allowBlockFlag")
        if obj != nil {
            return obj as? Bool
        }
        return nil
        
    }
    public func saveAutoUpdate(autoUpdate: Bool){
        Defaults[.autoUpdate] = autoUpdate
    }
    public func loadAutoUpdate() -> Bool?{
        if Defaults[.autoUpdate] != nil {
            return Defaults[.autoUpdate]!
        }
        return nil
        
    }
    public func getLoadedCallers() -> [Caller]{
        var callers = [Caller]()
        do{
            
            callers = try LocalDataManager.sharedInstance.CALLER_DATA_HELPER.findAll()!
            
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
            let idCaller = try LocalDataManager.sharedInstance.CALLER_DATA_HELPER.insert(item: caller)
            for callerCategory in caller.categories! {
                callerCategory.callerId = idCaller
            }
            try LocalDataManager.sharedInstance.CALLER_CATEGORY_DATA_HELPER.insertAll(items: caller.categories!)
            self.reloadExtension()
            return idCaller > 0
        }catch {
            print("Insert new Caller failed")
            return false
            
        }
    }
    public func updateCaller(caller: Caller) -> Bool{
        do{
            let id = try LocalDataManager.sharedInstance.CALLER_DATA_HELPER.update(cid: caller.callerId!, updatedItem: caller)
            self.reloadExtension()
            return id
        }catch {
            print("Insert new Caller failed")
            return false
            
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
    
    public func startDataRequest(reachability: Reachability,allowCell: Bool, completionHandler: @escaping (_ result: Bool) -> Void){
    
        NetworkManager.sharedInstance.requestIfReachableViaWiFi(reachability: reachability,allowCell: allowCell, requestingHandler: syncUpCallers, completionHandler: completionHandler)
    }
    public func syncUpCallers(completionHandler: @escaping (_ result: Bool) -> Void){
        DataService.sharedInstance.syncUpCallers(completionHandler:completionHandler)
    }
    
}
