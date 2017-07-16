//
//  Configuration.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 7/16/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//


class Configuration {
    static let sharedInstance = Configuration()
    public func getLocale() -> String{
        return Constants.LOCALE_DEFAULT
    }

}
