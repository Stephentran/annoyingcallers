//
//  AddContactViewController.swift
//  CallBlock
//
//  Created by Stephen Tran on 7/1/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import UIKit
import os.log
import class DataManager.Category
import class DataManager.Caller
import class DataManager.CallerCategory
import class DataManager.DataService
import class DataManager.LocalDataManager
import Reachability
import MRCountryPicker
import SwiftValidator
class ContactViewController: UIViewController, UITextFieldDelegate, ValidationDelegate, MRCountryPickerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var countryName: UILabel!
    
    @IBOutlet weak var category: UILabel!

    @IBOutlet weak var countryFlag: UIImageView!
    @IBOutlet weak var phoneCode: UILabel!
    @IBOutlet weak var countryCode: UILabel!
    @IBOutlet weak var countryPicker: MRCountryPicker!
    
    @IBOutlet weak var contactPhoneNumber: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    var caller: Caller?
    var pickerData: [Category]? = [Category]()
    var categorySelected: Category?
    let reachability = Reachability()!
    let validator = Validator()
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        validator.registerField(contactPhoneNumber, rules: [RequiredRule(), PhoneNumberRule()])
        
        countryPicker.countryPickerDelegate = self
        countryPicker.showPhoneNumbers = true

        // set country by its code
        countryPicker.setCountry(Constants.COUNTRY_CODE_DEFAULT)
        // Handle the text field’s user input through delegate callbacks.
        contactPhoneNumber.delegate = self
        
         // Enable the Save button only if the text field has a valid Meal name.
        //updateSaveButtonState()


        // Connect data:
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        
        //let tap = UITapGestureRecognizer(target: self, action: "handleKeyboard:")
        //view.addGestureRecognizer(tap)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapView(_:)))
        //tapRecognizer.addTarget(self, action: #selector(ViewController.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DataService.sharedInstance.requestCategories(url: Constants.SERVICE_CATEGORY_URL, completionHandler: { Void in
            self.loadDataForCategoryPicker()
        })
        
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
    //MARK: Actions
    
    
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        backToBlockListView()
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
            fatalError("The ContactViewController is not inside a navigation controller.")
        }
    }
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        validator.validate(self)
        
    }
    func submitNewNumber()  {
        let phoneNumber = contactPhoneNumber.text ?? ""
        let countryCode = self.countryCode.text ?? ""
        
        let callerCategory = CallerCategory.createCallerCategory(id: nil, callerId: nil, categoryId: categorySelected?.categoryId, assignType: Caller.ASSIGN_TYPE_PRIVATE, assignedDate: Date(), isLocal: true, categoryName: categorySelected?.categoryName)
        let caller = Caller.createCaller(
                        callerId: nil,
                        countryCode: countryCode,
                        callerNumber: phoneNumber,
                        registeredByDevice: Constants.REGISTERED_DEVICE_ID,
                        registeredDate: Date(),
                        isLocal: true,
                        isLocalBlocked: false,
                        categories: [callerCategory]
                    )
        
        let ret = LocalDataManager.sharedInstance.insertCaller(caller: caller)
        if ret == false {
            let alert = UIAlertController(title: "Alert", message: "Can not report this number", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else {
            LocalDataManager.sharedInstance.startDataRequest(callerUrl: Constants.SERVICE_CALLER_URL, categoryUrl: Constants.SERVICE_CATEGORY_URL, reachability: reachability,allowCell: Constants.USING_CELLULAR_FOR_REQUEST, completionHandler: completionHandler)
        }

    }
    func completionHandler(result: Bool){
        if result == true {
            backToBlockListView()
        }
        
    }
     //MARK: UITextFieldDelegate 
     func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        //saveButton.isEnabled = false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        //updateSaveButtonState()
        navigationItem.title = textField.text
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    func didTapView(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true);
    }
    //MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = contactPhoneNumber.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    //MARK: MRCountryPickerDelegate
    // a picker item was selected
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        self.countryName.text = name
        self.countryCode.text = countryCode
        self.phoneCode.text = phoneCode
        self.countryFlag.image = flag
    }
    func loadDataForCategoryPicker(){
        let categories = LocalDataManager.sharedInstance.getLoadedCategories()
            self.pickerData = [Category]()
            for category in categories {
                self.pickerData?.append(category)
            }
            self.categoryPicker.reloadAllComponents()
        
        
        
    }
    
    //MARK: UIPickerViewDelegate,UIPickerViewDataSource
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData!.count > 4 ? 4 : pickerData!.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData?[row].categoryName
    }
    // Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.category.text = pickerData?[row].categoryName
        categorySelected = pickerData?[row]
        saveButton.isEnabled = true
    }
    
    //MARK: ValidationDelegate
    func validationSuccessful() {
        submitNewNumber()
    }

    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.red.cgColor
                field.layer.borderWidth = 1.0
		}
		error.errorLabel?.text = error.errorMessage // works if you added labels
		error.errorLabel?.isHidden = false
	}
}
}
