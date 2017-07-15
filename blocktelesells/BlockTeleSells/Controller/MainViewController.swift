//
//  MainViewController.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 7/6/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import UIKit
import Reachability
import DataManager
import CallKit
//CXCallObserverDelegate
class MainViewController: UIViewController {

    @IBOutlet weak var gotoList: UIButton!
    
    let reachability = Reachability()!
    @IBOutlet weak var updatedStatus: UILabel!
    override func viewDidLoad() {
        //CXCallObserver *callObserver = CXCallObserver();
        super.viewDidLoad()
        loadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func loadData(){
        startNetworkingListener()
        let latestDate = DataManager.sharedInstance.loadUpdatedStatus()
        if(latestDate != nil){
            self.updatedStatus.text = latestDate?.description
        }
        
        
    }
    private func startNetworkingListener(){
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
                    DataService.sharedInstance.requestCallers(url: Constants.SERVICE_CALLER_URL, completionHandler: {Void in
                        
                        DataManager.sharedInstance.saveUpdatedStatus(latestDate: Date())
                        self.updatedStatus.text = DataManager.sharedInstance.loadUpdatedStatus()?.description
                    })
                    DataService.sharedInstance.requestCategories(url: Constants.SERVICE_CATEGORY_URL, completionHandler: { Void in
            
                    })
                } else {
                    print("Reachable via Cellular")
                    let alert = UIAlertController(title: "Alert", message: "We just got Cellular", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                print("Not reachable")
                let alert = UIAlertController(title: "Alert", message: "There is no network connection", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
            }
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

}
