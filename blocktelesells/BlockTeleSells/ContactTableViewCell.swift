//
//  ContactTableViewCell.swift
//  CallBlock
//
//  Created by Stephen Tran on 6/30/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import UIKit
import DataManager
class ContactTableViewCell: UITableViewCell {
    @IBOutlet weak var contactPhoneNumber: UILabel!
    @IBOutlet weak var contactDescription: UITextView!
        override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var caller: Caller?
    @IBAction func blockedToggle(_ sender: Any) {
        if callerBlocked.isOn {
            caller?.isLocalBlocked = true;
        }else{
            caller?.isLocalBlocked = false;
        }
        LocalDataManager.sharedInstance.updateCaller(caller: caller!)
        
    }
    
    @IBOutlet weak var callerBlocked: UISwitch!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
