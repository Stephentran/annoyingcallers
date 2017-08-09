//
//  SettingsViewController.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 8/9/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import UIKit
import DataManager
class SettingsViewController: UIViewController {
    @IBOutlet weak var switchBlockCall: UISwitch!
    @IBOutlet weak var switchAutoUpdate: UISwitch!

    @IBAction func blockCalls(_ sender: UISwitch) {
        LocalDataManager.sharedInstance.saveBlockCall(blockCall: switchBlockCall.isOn)
        LocalDataManager.sharedInstance.reloadExtension()
        
    }
    @IBAction func allowAutoUpdate(_ sender: UISwitch) {
        LocalDataManager.sharedInstance.saveAutoUpdate(autoUpdate: switchAutoUpdate.isOn)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchBlockCall.setOn(LocalDataManager.sharedInstance.loadBlockCall()!, animated: false)
        switchAutoUpdate.setOn(LocalDataManager.sharedInstance.loadAutoUpdate()!, animated: false)
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

}
