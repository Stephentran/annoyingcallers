//
//  ContactTableViewCell.swift
//  CallBlock
//
//  Created by Stephen Tran on 6/30/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    @IBOutlet weak var contactPhoneNumber: UILabel!
    @IBOutlet weak var contactDescription: UITextView!
        override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
