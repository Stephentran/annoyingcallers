//
//  NetworkManager.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 7/22/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import Reachability
public class NetworkManager {
    public static let sharedInstance = NetworkManager()
    var allowCellular = false;
    public func requestIfReachableViaWiFi(reachability: Reachability,allowCell: Bool, requestingHandler: @escaping (_ completionHandler: @escaping (_ result: Bool) -> Void) -> Void, completionHandler: @escaping (_ result: Bool) -> Void) {
        NetworkManager.sharedInstance.configureAllowCellular(allowCell: allowCell)
        if reachability.isReachableViaWiFi || (reachability.isReachable && self.allowCellular)  {
            if LocalDataManager.sharedInstance.loadKeytToken() != nil {
                requestingHandler(completionHandler)
            }else{
                DataService.sharedInstance.requestToken(completionHandler: {
                    requestingHandler(completionHandler)
                })
            }
                    
        } else if(reachability.isReachable){
            print("Reachable via Cellular")
                
        }else {
            completionHandler(false)
        }
        /*
        else{
            reachability.whenReachable = { reachability in
                // this is called on a background thread, but UI updates must
                // be on the main thread, like this:
                DispatchQueue.main.async {
                    if reachability.isReachableViaWiFi || (reachability.isReachable && self.allowCellular)  {
                        if LocalDataManager.sharedInstance.loadKeytToken() != nil {
                            requestingHandler(completionHandler)
                        }else{
                                DataService.sharedInstance.requestToken(completionHandler: {
                                requestingHandler(completionHandler)
                            })
                        }
                    
                    } else {
                        print("Reachable via Cellular")
                    }
                }
            }
            reachability.whenUnreachable = { reachability in
                // this is called on a background thread, but UI updates must
                // be on the main thread, like this:
                DispatchQueue.main.async {
                    print("Unreachable via Network")
                }
            }

            do {
                try reachability.startNotifier()
            } catch {
                print("Unable to start notifier")
            }
        }
        */
        
        
    }
    public func configureAllowCellular(allowCell: Bool){
        self.allowCellular = allowCell
    }

}
