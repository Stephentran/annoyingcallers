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
    public func requestIfReachableViaWiFi(url: String, reachability: Reachability,allowCell: Bool, requestingHandler: @escaping (_ url: String, _ completionHandler: @escaping (_ result: Bool) -> Void) -> Void, completionHandler: @escaping (_ result: Bool) -> Void) {
        NetworkManager.sharedInstance.configureAllowCellular(allowCell: allowCell)
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi || (reachability.isReachable && self.allowCellular)  {
                    requestingHandler(url, completionHandler)
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
    public func configureAllowCellular(allowCell: Bool){
        self.allowCellular = allowCell
    }

}
