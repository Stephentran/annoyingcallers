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
    public static let instance = DataService()
    
    var callers : [Caller]
    private init() {
        callers = [Caller]();
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
    public func requestCallers(url: String, completionHandler: @escaping (String) -> Void) {
        callers = [Caller]();
        
        Alamofire.request(url).responseArray { (response: DataResponse<[Caller]>) in
            let callerArray = response.result.value
            if let callerArray = callerArray {
                for caller in callerArray {
                    self.callers.append(caller)
                    print(caller.callerNumber ?? "No Data")
                }
            }
            
            do{
                try CallerDataHelper.insertAll(items: self.callers)
            }catch{
                print("Sqlite saving failed")
            }
            completionHandler("LoadedCallers")
            self.reloadExtension()
        }
        
    }
    
    public func getLoadedCallers() -> [Caller]{
        return self.callers;
    }
    
    
}
