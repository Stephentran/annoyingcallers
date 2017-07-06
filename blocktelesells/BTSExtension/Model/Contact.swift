//
//  Contact.swift
//  CallBlock
//
//  Created by Stephen Tran on 6/30/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import Foundation
class Contact2{
    let id: Int64?
    let phoneNumber: String
    let firstName: String
    let lastName: String
    let description: String
    init(id: Int64, phoneNumber: String, firstName: String, lastName: String ,description: String){
        self.firstName = firstName;
        self.lastName = lastName;
        self.description = description;
        self.phoneNumber = phoneNumber;
        self.id = id;
    }

}
