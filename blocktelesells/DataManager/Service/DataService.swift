//
//  DataService.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 7/7/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import Alamofire
public class DataService{
    public static let instance = DataService()
    private init() {
    }
    public func getContacts() -> [Contact] {
        Alamofire.request("http://127.0.0.1:8000/callers/").responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result

            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
            }

            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
        }
        return [Contact]();
    }
    
}
