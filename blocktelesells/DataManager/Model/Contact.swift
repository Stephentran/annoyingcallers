//
//  Contact.swift
//  CallBlock
//
//  Created by Stephen Tran on 6/30/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import Foundation
public class Contact{
    public let id: Int64?
    public let phoneNumber: String
    public let firstName: String
    public let lastName: String
    public let description: String
    public init(id: Int64, phoneNumber: String, firstName: String, lastName: String ,description: String){
        self.firstName = firstName;
        self.lastName = lastName;
        self.description = description;
        self.phoneNumber = phoneNumber;
        self.id = id;
    }

}
