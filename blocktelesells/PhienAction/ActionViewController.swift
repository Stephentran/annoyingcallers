//
//  ActionViewController.swift
//  PhienAction
//
//  Created by Stephen Tran on 8/25/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import UIKit
import MobileCoreServices
import Contacts
import ContactsUI
import  Foundation
import Eureka
import PhoneNumberKit
import DataManager
class ActionViewController: FormViewController {

    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var contactPhoneNumber: LabelRow?
    var contactInfo : LabelRow?
    let phoneNumberKit = PhoneNumberKit()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        
        ///////////////////////////////////////
        
        contactPhoneNumber = LabelRow("PhoneNumber"){
            $0.value = ""
            
        }.onChange {_ in 
            self.form.rowBy(tag: "PhoneNumber")?.reload()
        }.cellUpdate({ (cell, row) in
            cell.textLabel?.textAlignment = .center
        })
        
        contactInfo = LabelRow("ContactInfo"){
            $0.value = ""
            
        }.onChange {_ in 
            self.form.rowBy(tag: "ContactInfo")?.reload()
        }.cellUpdate({ (cell, row) in
            cell.textLabel?.textAlignment = .center
        })
        
        let goToApp =  ButtonRow("GoToApp"){ row in
            row.title = "Chia sẻ với Phiền"
        }.onCellSelection { cell, row in
            let url = URL(string: "call-block-main-screen://NewContactViewController")!
            if self.openURL(url) == false {
                print("There is a error during opening app")
            }
        }
        let done =  ButtonRow("Done"){ row in
            row.title = "Tắt"
        }.onCellSelection { cell, row in
            self.done()
        }
        
        form
            
            +++ Section("Số điện thoại")
            <<< contactPhoneNumber!
            +++ Section("Thông tin")
            <<< contactInfo!
            +++ Section("")
            <<< goToApp
            <<< done
        getContact()
        
        ///////////////////////////////////////
        
    }
    func getContact() -> Void {
        
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            
            for provider in item.attachments! as! [NSItemProvider] {
        
                if provider.hasItemConformingToTypeIdentifier(kUTTypeContact as String) {
                    provider.loadItem(forTypeIdentifier: kUTTypeContact as String, options: nil, completionHandler: { (contact, error) in
                        if error == nil {
                           do {
                                let contacts = try CNContactVCardSerialization.contacts(with: contact as! Data)
                                if contacts.count > 0 {
                                    let cnContact = contacts[0]
                                    if (cnContact.phoneNumbers.count) > 0 {
                                        DispatchQueue.main.async {
                                            self.contactPhoneNumber?.value = cnContact.phoneNumbers[0].value.stringValue
                                            do {
                                                let phoneNumber = try self.phoneNumberKit.parse((self.contactPhoneNumber?.value)!)
                                                if phoneNumber.type == PhoneNumberType.mobile {
                                                    self.contactInfo?.value = "Số di động"
                                                }else {
                                                    self.contactInfo?.value = "Số cố định"
                                                }
                                                LocalDataManager.sharedInstance.saveCopiedPhoneNumber(copiedPhoneNumber: (self.contactPhoneNumber?.value)!)
                                            }
                                            catch {
                                                    print("Generic parser error")
                                                }
                                            }
                                        }
                                    }
                                        
                            } catch {
                                    print("There is a error during loading item")
                            }
                        }
                    })
                }
                
            }
        }
    }
    //  Function must be named exactly like this so a selector can be found by the compiler!
//  Anyway - it's another selector in another instance that would be "performed" instead.
    func openURL(_ url: URL) -> Bool {
        
        var responder: UIResponder? = self
        while responder != nil {
            if (responder as? UIApplication) != nil {
                
                if ((responder as? UIApplication)?.canOpenURL(url))! == true {
                    LocalDataManager.sharedInstance.saveComeFromActionExtensionFlag(comeFromActionExtensionFlag: true)
                    return responder!.perform(#selector(openURL(_:)), with: url) != nil
                }
            }
            responder = responder?.next
        }
        return false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    private func initialize() {
        
        let doneButton = UIBarButtonItem(title: "Đóng", style: .plain, target: self, action: .done)
        navigationItem.leftBarButtonItem = doneButton
    
        
    }
    
    // MARK: - Actions
    @objc fileprivate func done(_ sender: UIBarButtonItem) {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}
// MARK: - Selectors
extension Selector {
    fileprivate static let done = #selector(ActionViewController.done(_:))
}
