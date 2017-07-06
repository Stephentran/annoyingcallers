//
//  AddContactViewController.swift
//  CallBlock
//
//  Created by Stephen Tran on 7/1/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import UIKit
import os.log
import DataManager
class ContactViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var contactLastName: UITextField!
    @IBOutlet weak var contactFirstName: UITextField!
    @IBOutlet weak var contactPhoneNumber: UITextField!
    @IBOutlet weak var contactDescription: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    var contact: Contact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        contactPhoneNumber.delegate = self
        // Set up views if editing an existing Meal.
        if let contact = contact {
            navigationItem.title = contact.firstName + " " + contact.lastName
            contactFirstName.text = contact.firstName
            contactLastName.text   = contact.lastName
            contactPhoneNumber.text = contact.phoneNumber
            contactDescription.text = contact.description
        }
         // Enable the Save button only if the text field has a valid Meal name.
        updateSaveButtonState()


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
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        let firstName = contactFirstName.text ?? ""
        let lastName = contactLastName.text ?? ""
        let phoneNumber = contactPhoneNumber.text ?? ""
        let description = contactDescription.text ?? ""
        let cid = contact?.id
        
        if(contact != nil && contact?.id != nil){
            let contactForSave = Contact(id: cid!, phoneNumber: phoneNumber, firstName: firstName, lastName: lastName ,description: description)
            if DataManager.instance.updateContact(cid: cid!, newContact: contactForSave){
                contact = Contact(id: cid!, phoneNumber: phoneNumber, firstName: firstName, lastName: lastName ,description: description)
            }
        }else{
            let id = DataManager.instance.addContact(cfirstName: firstName,clastName: lastName, cphoneNumber: phoneNumber, cdescription: description)
            if id! > 0{
                contact = Contact(id: id!, phoneNumber: phoneNumber, firstName: firstName, lastName: lastName ,description: description)
            }
        }
        
        
        super.prepare(for: segue, sender: sender)
    }
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
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

     //MARK: UITextFieldDelegate 
     func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    //MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = contactPhoneNumber.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
}
