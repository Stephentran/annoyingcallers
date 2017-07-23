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
//, CXCallObserverDelegate
class MainViewController: UIViewController , CXCallObserverDelegate{

    @IBOutlet weak var gotoList: UIButton!
    var callObserver: CXCallObserver?
    let reachability = Reachability()!
    @IBOutlet weak var updatedStatus: UILabel!
    override func viewDidLoad() {
        self.callObserver = CXCallObserver()
        self.callObserver?.setDelegate(self, queue: nil)
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
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
        self.updateData()
        let latestDate = LocalDataManager.sharedInstance.loadUpdatedStatus()
        if(latestDate != nil){
            self.updatedStatus.text = Common.sharedInstance.formatDate(date: latestDate!)
        }
        
        
    }
    public func updateData(){
        LocalDataManager.sharedInstance.startDataRequest(url: Constants.SERVICE_CALLER_URL, reachability: reachability,allowCell: Constants.USING_CELLULAR_FOR_REQUEST, completionHandler: completionHandler)
        //LocalDataManager.sharedInstance.syncUpCallers(url: Constants.SERVICE_CATEGORY_URL, completionHandler:completionHandler)
        
    }
    
    func completionHandler(result: Bool){
        if result == true {
            self.updatedStatus.text = Common.sharedInstance.formatDate(date: LocalDataManager.sharedInstance.loadUpdatedStatus()!)
        }
        
    }
    
    //MARK: CallObserver
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall){
        if (call.hasConnected) {
            NSLog("********** voice call connected **********/n");
        } else if(call.hasEnded) {
            NSLog("********** voice call disconnected **********/n");
        }
    }
    

}
