//
//  NewContactViewController.swift
//  Phiền
//
//  Created by Stephen Tran on 8/20/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import UIKit
import Eureka
import Reachability
import class DataManager.Category
import class DataManager.Caller
import class DataManager.CallerCategory
import class DataManager.DataService
import class DataManager.LocalDataManager
class NewContactViewController: FormViewController {
    var pickerData: [Category]? = [Category]()
    var categoryPicker: PickerRow<Category>?
    var contactPhoneNumber: PhoneRow?
    var categorySelected: Category?
    let reachability = Reachability()!
 
 
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        loadDataForCategoryPicker()
        
        ///////////////////////////////////////
        
        contactPhoneNumber = PhoneRow(){ 
                $0.placeholder = "Nhập số điện thoại"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMinLength(minLength: 10, msg: "Số điện thoại không hợp lệ"))
                $0.add(rule: RuleMaxLength(maxLength: 16, msg: "Số điện thoại không hợp lệ"))
                let defaultCellColor = $0.cell.layer.borderColor
                let borderWidth = $0.cell.layer.borderWidth
            
                $0.cellUpdate { (cell, row) in //3
                    if !row.isValid {
                        cell.layer.borderColor = UIColor.red.cgColor
                        cell.layer.borderWidth = 1.0
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                        
                    }else{
                        if self.contactPhoneNumber?.value != nil {
                            cell.layer.borderColor = defaultCellColor
                            cell.layer.borderWidth = borderWidth
                            if (self.pickerData?.count)! > 0 {
                                self.navigationItem.rightBarButtonItem?.isEnabled = true
                            }
                            
                        }
                        
                    }
                }
                $0.validationOptions = .validatesOnChangeAfterBlurred
            
        }
        categoryPicker = PickerRow<Category>() {
                $0.options = pickerData!
                $0.displayValueFor = { (category: Category?) in
                    return category?.categoryName
                }
                $0.add(rule: RuleRequired())
        }.onChange({ (row) in
            self.categorySelected = row.value
        })
        
        form
            +++ Section("Số điện thoại")
            <<< contactPhoneNumber!
            +++ Section("Thể loại phiền")
            <<< categoryPicker!
        
        ///////////////////////////////////////
        
        if LocalDataManager.sharedInstance.loadCopiedPhoneNumber() != nil {
            contactPhoneNumber?.value = LocalDataManager.sharedInstance.loadCopiedPhoneNumber()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initialize() {
        
        let deleteButton = UIBarButtonItem(image: UIImage(named: "arrow2424.png"), style: .plain, target: self, action: .cancelButtonPressed)
        navigationItem.leftBarButtonItem = deleteButton
    
        let saveButton = UIBarButtonItem(image: UIImage(named: "save.png"), style: .plain, target: self, action: .saveButtonPressed)
        
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.rightBarButtonItem?.isEnabled = false
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //MARK: - PickerRow
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return pickerData!.count > 4 ? 4 : pickerData!.count
    }

   

    open func pickerView(_ pickerView: UIPickerView, didSelectRow rowNumber: Int, inComponent component: Int){
    }
    // MARK: utility functions
    func loadDataForCategoryPicker(){
        let categories = LocalDataManager.sharedInstance.getLoadedCategories()
        self.pickerData = [Category]()
        for category in categories {
            self.pickerData?.append(category)
        }
    }
    // MARK: - Actions
    @objc fileprivate func saveButtonPressed(_ sender: UIBarButtonItem) {
        if (contactPhoneNumber?.isValid)! && (categoryPicker?.isValid)! && categorySelected != nil {
            submitNewNumber()
        }
    }
  
    @objc fileprivate func cancelButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: Constants.ALERT_TITLE, message: Constants.CONFIRM_MESSAGE_IN_NEW_CONTACT, preferredStyle: UIAlertControllerStyle.alert)
        
            alert.addAction(UIAlertAction(title: Constants.ALERT_BUTTON_CANCEL, style: UIAlertActionStyle.default, handler: confirmBeforeExit))
        
            alert.addAction(UIAlertAction(title: Constants.ALERT_BUTTON_EXIT, style: UIAlertActionStyle.destructive, handler: confirmBeforeExit))
        
            self.present(alert, animated: true, completion: nil)
    }
    func confirmBeforeExit(action: UIAlertAction){
        if action.title == Constants.ALERT_BUTTON_EXIT {
            _ = navigationController?.popViewController(animated: true)
        }
       
    }
    
    
    //MARK: Actions
    func submitNewNumber()  {
        let phoneNumber = contactPhoneNumber?.value?.replacingOccurrences(of: " ", with: "") ?? ""
        
        let callerCategory = CallerCategory.createCallerCategory(id: nil, callerId: nil, categoryId: categorySelected?.categoryId, assignType: Caller.ASSIGN_TYPE_PRIVATE, assignedDate: Date(), isLocal: true, categoryName: categorySelected?.categoryName)
        let caller = Caller.createCaller(
                        callerId: nil,
                        countryCode: Constants.COUNTRY_CODE_DEFAULT,
                        callerNumber: phoneNumber,
                        registeredByDevice: UIDevice.current.identifierForVendor!.uuidString,
                        registeredDate: Date(),
                        isLocal: true,
                        isLocalBlocked: false,
                        categories: [callerCategory]
                    )
        
        let ret = LocalDataManager.sharedInstance.insertCaller(caller: caller)
        
        if ret == false {
            let alert = UIAlertController(title: Constants.ALERT_TITLE, message: Constants.INSERT_DB_ERROR, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: Constants.ALERT_BUTTON_OK, style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else {
            
            LocalDataManager.sharedInstance.startDataRequest(reachability: reachability,allowCell: Constants.USING_CELLULAR_FOR_REQUEST, completionHandler: completionHandler)
        }

    }
    func completionHandler(result: Bool){
        if result == true {
            LocalDataManager.sharedInstance.clearCopiedPhoneNumber()
            let alert = UIAlertController(title: Constants.ALERT_TITLE, message: Constants.SHARED_SUCCESFULLY, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: Constants.ALERT_BUTTON_OK, style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.backToBlockListView()}))
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: Constants.ALERT_TITLE, message: Constants.NO_NETWORK_CONNECTION, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: Constants.ALERT_BUTTON_OK, style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.backToBlockListView()}))
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    func backToBlockListView(){
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
    
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            print("The ContactViewController is not inside a navigation controller.")
        }
    }
}
// MARK: - Selectors
extension Selector {
    fileprivate static let saveButtonPressed = #selector(NewContactViewController.saveButtonPressed(_:))
    fileprivate static let cancelButtonPressed = #selector(NewContactViewController.cancelButtonPressed(_:))
}
