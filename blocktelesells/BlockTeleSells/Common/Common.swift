//
//  Common.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 7/16/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//


import UIKit
class Common{
    static let sharedInstance = Common()
    public func formatDate(date: Date) -> String{
        let usDateFormat = DateFormatter()
        usDateFormat.dateFormat = "yyyy-MM-dd HH:mm"
        usDateFormat.locale = Locale(identifier: Configuration.sharedInstance.getLocale())
        return usDateFormat.string(from : date)
    }

}
