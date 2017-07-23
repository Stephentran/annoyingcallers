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
    
    public func syncUpCallers(url: String, completionHandler: @escaping (_ result: Bool) -> Void){
        do{
            let callers = try LocalDataManager.sharedInstance.CALLER_DATA_LOCAL_HELPER.findAll()
            for caller in callers! {
                caller.callerId = nil
            }
            let jsonStringArrayEncoding = JSONStringArrayEncoding(array: Mapper<Caller>().toJSONArray(callers!))
        
            let headers: HTTPHeaders = [ "Content-Type": "application/json"]
            Alamofire.request(url, method: HTTPMethod.post, parameters: [:], encoding: jsonStringArrayEncoding, headers: headers).responseArray{
                (response: DataResponse<[Caller]>) in
                    if(response.result.isSuccess) {
                        self.handleCallerResponse(callerArray: response.result.value!)
                    
                    }
                    completionHandler(response.result.isSuccess)
                }
        }catch{
            print("There is some error during syncing server")
            completionHandler(false)
        }
        
    }
    func handleCallerResponse(callerArray: [Caller]){
        var newCallers = [Caller]();
        var updateCallers = [Caller]();
        do{
            for caller in callerArray {
                if try LocalDataManager.sharedInstance.CALLER_DATA_HELPER.find(id: caller.callerId!) != nil {
                    updateCallers.append(caller)
                }else {
                    newCallers.append(caller)
                }
            }
            _ = try LocalDataManager.sharedInstance.CALLER_DATA_HELPER.updateAll(items: updateCallers)
            _ = try LocalDataManager.sharedInstance.CALLER_DATA_HELPER.insertAll(items: newCallers)
            LocalDataManager.sharedInstance.reloadExtension()
        }catch{
            print("Sqlite saving failed")
        }
    }
    public func requestCallers(url: String, completionHandler: @escaping () -> Void) {
        
        Alamofire.request(url).responseArray { (response: DataResponse<[Caller]>) in
            if(response.result.isSuccess) {
                self.handleCallerResponse(callerArray: response.result.value!)
            }
            completionHandler()
            
        }
        
    }
    
    public func requestCategories(url: String, completionHandler: @escaping () -> Void) {
        var newCategories = [Category]();
        var updateCategories = [Category]();
        
        Alamofire.request(url).responseArray { (response: DataResponse<[Category]>) in
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
    
    
    
    
}
