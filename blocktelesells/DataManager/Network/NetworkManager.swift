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
    public func requestIfReachableViaWiFi(reachability: Reachability, requestingHandler: @escaping () -> Void, alertWhenCellular: @escaping () -> Void, alertWhenNoNetwork: @escaping () -> Void) {
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi || (reachability.isReachable && self.allowCellular)  {
                    requestingHandler()
                } else {
                    print("Reachable via Cellular")
                    alertWhenCellular()
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                alertWhenNoNetwork()
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
