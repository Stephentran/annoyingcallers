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
import CallKit
public class DataService{
    public static let sharedInstance = DataService()
    
    
    private init() {
    }
    private func reloadExtension(){
        let callDirManager = CXCallDirectoryManager.sharedInstance;
        callDirManager.reloadExtension(withIdentifier: DataManager.CBX_IDENTIFIER,
            completionHandler: {(error) in
            
                if (error == nil)
                {
                    print("Reloaded extension successfully")
                } else {
                    print("Reloaded extension failed with ")
                }
            
        })
    }
    public func requestCallers(url: String, completionHandler: @escaping () -> Void) {
        var callers = [Caller]();
        
        Alamofire.request(url).responseArray { (response: DataResponse<[Caller]>) in
            if(response.result.isSuccess) {
                let callerArray = response.result.value
                if let callerArray = callerArray {
                    for caller in callerArray {
                        callers.append(caller)
                        print(caller.callerNumber ?? "No Data")
                    }
                }
            
                do{
                    _ = try CallerDataHelper.insertAll(items: callers)
                    self.reloadExtension()
                }catch{
                    print("Sqlite saving failed")
                }
            }
            
            completionHandler()
            
        }
        
    }
    public func requestCategories(url: String, completionHandler: @escaping () -> Void) {
        var categories = [Category]();
        
        Alamofire.request(url).responseArray { (response: DataResponse<[Category]>) in
            if(response.result.isSuccess) {
                let categoryArray = response.result.value
                if let categoryArray = categoryArray {
                    for category in categoryArray {
                        categories.append(category)                }
                    }
            
                do{
                    _ = try CategoryDataHelper.insertAll(items: categories)
                }catch{
                    print("Sqlite saving failed")
                }
            }
            
            completionHandler()
            
        }
        
    }
    
    public func getLoadedCallers() -> [Caller]{
        do{
            return try CallerDataHelper.findAll()!
        }catch{
            print("Get all Categories failed")
        }
        return [Caller]()
    }
    public func getLoadedCategories() -> [Category]{
        do{
            return try CategoryDataHelper.findAll()!
        }catch{
            print("Get all Categories failed")
        }
        return [Category]()
    }
    public func insertCaller(caller: Caller) -> Bool{
        do{
            let id = try CallerDataHelper.insert(item: caller)
            self.reloadExtension()
            return id > 0
        }catch {
            print("Insert new Caller failed")
            return false
            
        }
    }
    
    
}
