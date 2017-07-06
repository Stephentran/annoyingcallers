//
//  CallDirectoryHandler.swift
//  BTSExtension
//
//  Created by Stephen Tran on 7/2/17.
//  Copyright © 2017 STEPHENTRAN. All rights reserved.
//

import Foundation
import CallKit
import DataManager
class CallDirectoryHandler: CXCallDirectoryProvider {
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        let contacts = DataManager.instance.getContacts()
        do {
            try addBlockingPhoneNumbers(to: context, contacts: contacts)
        } catch {
            NSLog("Unable to add blocking phone numbers")
            let error = NSError(domain: "CallDirectoryHandler", code: 1, userInfo: nil)
            context.cancelRequest(withError: error)
            return
        }

        do {
            try addIdentificationPhoneNumbers(to: context, contacts: contacts)
        } catch {
            NSLog("Unable to add identification phone numbers")
            let error = NSError(domain: "CallDirectoryHandler", code: 2, userInfo: nil)
            context.cancelRequest(withError: error)
            return
        }

        context.completeRequest()
    }

    private func addBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext, contacts: [Contact]) throws {
        // Retrieve phone numbers to block from data store. For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
        //
        // Numbers must be provided in numerically ascending order.
        
        var phones = DataManager.instance.getPhoneNumbers()
        let sortedKeys = Array(phones.keys).sorted(by: <)
        for (number) in sortedKeys {
            context.addBlockingEntry(withNextSequentialPhoneNumber: number)
        }
        
    }
    private func addIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext, contacts: [Contact]) throws {
        // Retrieve phone numbers to identify and their identification labels from data store. For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
        //
        // Numbers must be provided in numerically ascending order.
        
        var phones = DataManager.instance.getPhoneNumbers()
        let sortedKeys = Array(phones.keys).sorted(by: <)
        for (number) in sortedKeys {
            context.addIdentificationEntry(withNextSequentialPhoneNumber: number, label: phones[number]!)
        }
    }

}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // An error occurred while adding blocking or identification entries, check the NSError for details.
        // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
        //
        // This may be used to store the error details in a location accessible by the extension's containing app, so that the
        // app may be notified about errors which occured while loading data even if the request to load data was initiated by
        // the user in Settings instead of via the app itself.
    }

}
