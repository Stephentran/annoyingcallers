//
//  DataManager.swift
//  CallBlock
//
//  Created by Stephen Tran on 7/1/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import Foundation
import SQLite
import MMWormhole
import CallKit
public final class DataManager {
    public static let instance = DataManager()
    private let database: Connection?
    private let contacts = Table("contacts")
    private let id = Expression<Int64>("id")
    private let firstName = Expression<String?>("firstName")
    private let lastName = Expression<String?>("lastName")
    private let phoneNumber = Expression<String>("phoneNumber")
    private let description = Expression<String?>("description")
    private let wormhole = MMWormhole(applicationGroupIdentifier: "group.stephentran.callblock", optionalDirectory: "Contacts")
    // Can't init is singleton
    private init() {
        
        let fileManager = FileManager.default
        if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.stephentran.callblock") {
            let newDirectory = directory.appendingPathComponent("Contacts")
            try? fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: false, attributes: nil)
            do {
                database = try Connection("\(newDirectory)/CallBlock.sqlite3")
            } catch {
                database = nil
                print ("Unable to open database")
            }
            createTable()
        }else{
            print ("Unable to find group id")
            database = nil
        }
        DataService.instance.getContacts();
    }

    // MARK: Shared Instance

    private func notifyContactsUpdated(){
        wormhole.passMessageObject("Contact Updated" as NSCoding, identifier: "contacts")
        reloadExtension()
    }
    private func reloadExtension(){
        var callDirManager = CXCallDirectoryManager.sharedInstance;
 
        callDirManager.reloadExtension(withIdentifier: "com.ste.CallBlock.CallBlockExtension",
            completionHandler: {(error) in
            
                if (error == nil)
                {
                    print("Reloaded extension successfully")
                } else {
                    print("Reloaded extension failed with ")
                }
            
        })
    }
    func createTable() {
        do {
            try database!.run(contacts.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(firstName)
                table.column(lastName)
                table.column(phoneNumber, unique: true)
                table.column(description)
        })
        } catch {
            print("Unable to create table")
        }
    }
    public func addContact(cfirstName: String,clastName: String, cphoneNumber: String, cdescription: String) -> Int64? {
        do {
            let insert = contacts.insert(firstName <- cfirstName,lastName <- clastName, phoneNumber <- cphoneNumber, description <- cdescription)
            let id = try database!.run(insert)
            notifyContactsUpdated()
            return id
        } catch {
            print("Insert failed")
            return -1
        }
    }
    public func getPhoneNumbers() -> [Int64: String] {
        let contacts2 = getContacts();
        
        var dictionary =  [Int64 : String]()
        for contact in contacts2 {
            let number = Int64("84" + String(describing: Int64(contact.phoneNumber)!))
            dictionary.updateValue(contact.firstName + " " + contact.lastName, forKey:number!)
        }
        
        return dictionary
    }
    public func getContacts() -> [Contact] {
        var contacts = [Contact]()

        do {
            for contact in try database!.prepare(self.contacts) {
                contacts.append(Contact(
                id: contact[id],
                phoneNumber: contact[phoneNumber],
                firstName: contact[firstName]!,
                lastName: contact[lastName]!,
                description: contact[description]!))
            }
        } catch {
            print("Select failed")
        }
        
        return contacts
    }
    public func deleteContact(cid: Int64) -> Bool {
        do {
            let contact = contacts.filter(id == cid)
            try database!.run(contact.delete())
            notifyContactsUpdated()
            return true
        } catch {
            print("Delete failed")
        }
        return false
    }
    public func updateContact(cid:Int64, newContact: Contact) -> Bool {
        let contact = contacts.filter(id == cid)
        do {
            let update = contact.update([
                firstName <- newContact.firstName,
                lastName <- newContact.lastName,
                phoneNumber <- newContact.phoneNumber,
                description <- newContact.description
            ])
            if try database!.run(update) > 0 {
                notifyContactsUpdated()
                return true
            }
        } catch {
            print("Update failed: \(error)")
        }

    return false
}

}
