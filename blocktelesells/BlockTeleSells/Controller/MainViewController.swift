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
    
    @IBOutlet weak var reportedNumberCount: UILabel!
    
    @IBOutlet weak var gotoList: UIButton!
    var callObserver: CXCallObserver?
    let reachability = Reachability()!
    @IBOutlet weak var updatedStatus: UILabel!
    override func viewDidLoad() {
        self.callObserver = CXCallObserver()
        self.callObserver?.setDelegate(self, queue: nil)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if LocalDataManager.sharedInstance.loadBlockCall() == nil {
            LocalDataManager.sharedInstance.saveBlockCall(blockCall: false)
        }
        if LocalDataManager.sharedInstance.loadAutoUpdate() == nil {
            LocalDataManager.sharedInstance.saveAutoUpdate(autoUpdate: true)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
        if LocalDataManager.sharedInstance.loadComeFromActionExtensionFlag() == true {
            LocalDataManager.sharedInstance.saveComeFromActionExtensionFlag(comeFromActionExtensionFlag: false)
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "newContactViewController") as! NewContactViewController
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
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
        setUpdatedStatus()
        self.updateData()
        
    }
    private func setUpdatedStatus(){
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(withIdentifier: LocalDataManager.CBX_IDENTIFIER, completionHandler: {(status, error) -> Void in
            var message = Constants.NOT_CONNECT_SERVER
            if LocalDataManager.sharedInstance.loadUpdatedStatus() != nil {
                message = Constants.LATEST_UPDATED + Common.sharedInstance.formatDate(date: LocalDataManager.sharedInstance.loadUpdatedStatus()!)
            }
            if let error = error {
                print(error.localizedDescription)
            }
            if status != CXCallDirectoryManager.EnabledStatus.enabled {
                message = Constants.BLOCK_CALL_NOT_ENABLED
            }
            let nav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
            if nav?.visibleViewController is MainViewController {
                DispatchQueue.main.async() {
                    self.updatedStatus.text = message
                    self.reportedNumberCount.text = self.convertNumberToDisplayText(number: Double(LocalDataManager.sharedInstance.getLoadedCallers().count))
                }
            }
        })
        
    }
    func convertNumberToDisplayText(number: Double) -> String{
        let units = ["", Constants.K_UNIT, Constants.MIL_UNIT,Constants.BIL_UNIT]
        var index = 0
        var runValue = number
        while (runValue/1000.0 >= 1.0){
            index += 1
            runValue = runValue/1000.0
        }
        if index == 0 {
            return String(Int64(runValue))
        }else {
            return String(round(10*runValue)/10) + " " + units[index]
        }
        
    }
    public func updateData(){
        LocalDataManager.sharedInstance.startDataRequest(reachability: reachability,allowCell: Constants.USING_CELLULAR_FOR_REQUEST, completionHandler: completionHandler)
        
    }
    
    func completionHandler(result: Bool){
        setUpdatedStatus()
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
            
        }

        if call.hasConnected == true && call.hasEnded == false {
            print("Connected")
        }
    }
    
}
