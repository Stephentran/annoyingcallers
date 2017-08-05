//
//  DataService.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 7/7/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import Alamofire
import SwiftyJSON
import AlamofireObjectMapper

import ObjectMapper
public class DataService{
    public static let sharedInstance = DataService()
    
    
    private init() {
    }
    
    public func syncUpCallers(completionHandler: @escaping (_ result: Bool) -> Void){
        do{
            let callers = try LocalDataManager.sharedInstance.CALLER_DATA_HELPER.findAllByLocal(isLocal: true)
            for caller in callers {
                caller.callerId = nil
            }
            let jsonStringArrayEncoding = JSONStringArrayEncoding(array: Mapper<Caller>().toJSONArray(callers))
            
            let headers: HTTPHeaders = [ "Content-Type": "application/json", LocalDataManager.API_REQUEST_KEY:LocalDataManager.sharedInstance.loadKeytToken()!]
            Alamofire.request(LocalDataManager.SERVICE_CALLER_URL, method: HTTPMethod.post, parameters: [:], encoding: jsonStringArrayEncoding, headers: headers).responseArray{
                (response: DataResponse<[Caller]>) in
                    if(response.result.isSuccess) {
                        
                        DataService.sharedInstance.requestCategories(completionHandler: { Void in
                            self.handleCallerResponse(callerArray: response.result.value!)
                            completionHandler(response.result.isSuccess)
                        })                    
                    }
                
                }
        }catch{
            print("There is some error during syncing server")
            completionHandler(false)
        }
        
    }
    func handleCallerResponse(callerArray: [Caller]){
        var newCallers = [Caller]()
        var updateCallers = [Caller]()
        var callerCategories = [CallerCategory]()
        do{
            try LocalDataManager.sharedInstance.CALLER_DATA_HELPER.deleteAll()
            try LocalDataManager.sharedInstance.CALLER_CATEGORY_DATA_HELPER.deleteAll()
            for caller in callerArray {
                if try LocalDataManager.sharedInstance.CALLER_DATA_HELPER.find(id: caller.callerId!) != nil {
                    updateCallers.append(caller)
                    
                }else {
                    newCallers.append(caller)
                }
                callerCategories = callerCategories + caller.categories!
            }
            _ = try LocalDataManager.sharedInstance.CALLER_DATA_HELPER.insertAll(items: newCallers)
            _ = try LocalDataManager.sharedInstance.CALLER_CATEGORY_DATA_HELPER.insertAll(items: callerCategories)
            
            LocalDataManager.sharedInstance.saveUpdatedStatus(latestDate: Date())
            LocalDataManager.sharedInstance.reloadExtension()
                
        }catch{
            print("Sqlite saving failed")
        }
    }
    
    public func requestCallers(completionHandler: @escaping () -> Void) {
        
        let headers: HTTPHeaders = [ "Content-Type": "application/json", LocalDataManager.API_REQUEST_KEY:LocalDataManager.sharedInstance.loadKeytToken()!]
        Alamofire.request(LocalDataManager.SERVICE_CALLER_URL, parameters: [:], encoding: JSONEncoding.default, headers: headers).responseArray { (response: DataResponse<[Caller]>) in
            if(response.result.isSuccess) {
                self.handleCallerResponse(callerArray: response.result.value!)
                
            }
            completionHandler()
            
        }
        
    }
    
    public func requestCategories(completionHandler: @escaping () -> Void) {
        var newCategories = [Category]();
        var updateCategories = [Category]();
        let headers: HTTPHeaders = [ "Content-Type": "application/json", LocalDataManager.API_REQUEST_KEY:LocalDataManager.sharedInstance.loadKeytToken()!]
        Alamofire.request(LocalDataManager.SERVICE_CATEGORY_URL,parameters: [:], encoding: JSONEncoding.default, headers: headers).responseArray { (response: DataResponse<[Category]>) in
            if(response.result.isSuccess) {
                let categoryArray = response.result.value
                do{
                    if let categoryArray = categoryArray {
                        for category in categoryArray {
                            if ((try LocalDataManager.sharedInstance.CATEGORY_DATA_HELPER.find(id: category.categoryId!)) != nil) {
                                updateCategories.append(category)
                            }else {
                                newCategories.append(category)
                            }
                            
                        }
                    }
                    _ = try LocalDataManager.sharedInstance.CATEGORY_DATA_HELPER.updateAll(items: updateCategories)
                    _ = try LocalDataManager.sharedInstance.CATEGORY_DATA_HELPER.insertAll(items: newCategories)
                }catch{
                    print("Sqlite saving failed")
                }
            }
            
            completionHandler()
            
        }
        
    }
    public func requestToken(completionHandler: @escaping () -> Void) {
        
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        let device = Device.createDevice(id: uuid, platform: "iOS", owner: nil, status: 1, api_request_key: nil)
        let headers: HTTPHeaders = [ "Content-Type": "application/json"]
            Alamofire.request(LocalDataManager.SERVICE_TOKEN_URL, method: HTTPMethod.post, parameters: device.toJSON(), encoding: JSONEncoding.default, headers: headers).responseObject{
                (response: DataResponse<Device>) in
                    if(response.result.isSuccess) {
                        LocalDataManager.sharedInstance.saveKeytToken(keytToken: (response.result.value?.api_request_key)!)
                        completionHandler()
                        
                    }
                
                }
        
        
    }
    
    
}
