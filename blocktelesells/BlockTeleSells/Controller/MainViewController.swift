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
import AVFoundation
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
        LocalDataManager.sharedInstance.startDataRequest(reachability: reachability,allowCell: Constants.USING_CELLULAR_FOR_REQUEST, completionHandler: completionHandler)
        
    }
    
    func completionHandler(result: Bool){
        if result == true {
            self.updatedStatus.text = Common.sharedInstance.formatDate(date: LocalDataManager.sharedInstance.loadUpdatedStatus()!)
        }
    }
    
    //MARK: CallObserver
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall){
    //callObserver.calls
        if call.hasEnded == true {
            print("Disconnected")        }
        if call.isOutgoing == true && call.hasConnected == false {
            print("Dialing")
        }
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            print("Incoming " + call.uuid.uuidString + " " + call.uuid.description)
            
            /*
            let cXSetMutedCallAction = CXSetMutedCallAction(call:call.uuid, muted: true)
            let callController = CXCallController()
            // 2.
            let transaction = CXTransaction(action: cXSetMutedCallAction)
            callController.request(transaction) {
                error in
                if let error = error {
                    print("Error requesting transaction: \(error)")
                } else {
                    print("Requested transaction successfully")
                }
            }
            */
        }

        if call.hasConnected == true && call.hasEnded == false {
            print("Connected")
        }
    }
    
}
