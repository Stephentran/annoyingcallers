//
//  ResponseCollectionSerializable.swift
//  BlockTeleSells
//
//  Created by Stephen Tran on 7/23/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//
import Alamofire
import ObjectMapper
public struct JSONStringArrayEncoding: ParameterEncoding {
    private let array: [[String : Any]]

    init(array: [[String : Any]]) {
        self.array = array
    }

    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        let data = try JSONSerialization.data(withJSONObject: array, options: JSONSerialization.WritingOptions.prettyPrinted)

        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        urlRequest.httpBody = data

        return urlRequest
    }
}
