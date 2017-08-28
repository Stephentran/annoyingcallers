//
//  SettingsViewController.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 8/9/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import UIKit
import DataManager
import Eureka
import Presentation
class SettingsViewController: FormViewController, PresentationControllerDelegate {
    var switchBlockCall: SwitchRow?
    var switchAutoUpdate: SwitchRow?
    
    var window: UIWindow?
    var guideline: Guideline?
    func blockCalls() {
        LocalDataManager.sharedInstance.saveBlockCall(blockCall: (switchBlockCall?.value)!)
        LocalDataManager.sharedInstance.reloadExtension()
        
    }
    func allowAutoUpdate() {
        LocalDataManager.sharedInstance.saveAutoUpdate(autoUpdate: (switchAutoUpdate?.value)!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        
        switchBlockCall  = SwitchRow("SwitchRow") { row in      // initializer
                        row.title = "Bật để chặn các số phiền phức"
                    }.onChange { row in
                        row.updateCell()
                        self.blockCalls()
                    }.cellSetup { cell, row in
                        cell.backgroundColor = .lightGray
                    }.cellUpdate { cell, row in
                        cell.textLabel?.font = .italicSystemFont(ofSize: 18.0)
                }
        switchBlockCall?.value = LocalDataManager.sharedInstance.loadBlockCall()!
        switchAutoUpdate  = SwitchRow("SwitchRow") { row in      // initializer
                        row.title = "Bật để tự động cập nhật"
                    }.onChange { row in
                        row.updateCell()
                        self.allowAutoUpdate()
                        
                    }.cellSetup { cell, row in
                        cell.backgroundColor = .lightGray
                    }.cellUpdate { cell, row in
                        cell.textLabel?.font = .italicSystemFont(ofSize: 18.0)
                }
        switchAutoUpdate?.value = LocalDataManager.sharedInstance.loadAutoUpdate()!
        
        let help1 =  ButtonRow("Help"){ row in
            row.title = "Kích hoạt phiền"
        }.onCellSelection { cell, row in
            self.guideline = Guideline.showGuideLine(navigationController: self.navigationController!, presentationControllerDelegate: self)
        }
        
        let help2 =  ButtonRow("Help"){ row in
            row.title = "Lấy số nhanh từ lịch sử cuộc gọi"
        }.onCellSelection { cell, row in
            self.guideline = Guideline.showGuideLine(navigationController: self.navigationController!, presentationControllerDelegate: self)
        }
        form
            +++ Section("Tự động cập nhật")
            <<< switchAutoUpdate!
            +++ Section("Chặn số phiền phức")
            <<< switchBlockCall!
            +++ Section("Hướng dẫn sư dụng")
            <<< help1
            <<< help2
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
    private func initialize() {
        
        let deleteButton = UIBarButtonItem(image: UIImage(named: "arrow2424.png"), style: .plain, target: self, action: .deleteButtonPressed)
        navigationItem.leftBarButtonItem = deleteButton
    }
    @objc fileprivate func deleteButtonPressed(_ sender: UIBarButtonItem) {
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    //MARK: PresentationControllerDelegate
    public func presentationController(_ presentationController: Presentation.PresentationController, didSetViewController viewController: UIViewController, atPage page: Int){
        if guideline != nil {
            guideline?.handleMove(atPage: page)
        }
    }
}
// MARK: - Selectors
extension Selector {
    fileprivate static let deleteButtonPressed = #selector(SettingsViewController.deleteButtonPressed(_:))
}
