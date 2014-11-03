//
//  DiskFetcher.swift
//  Haneke
//
//  Created by Joan Romano on 9/16/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import Foundation

extension Haneke {

    // It'd be better to define this in the DiskFetcher class but Swift doesn't allow to declare an enum in a generic type
    public struct DiskFetcherGlobals {
        
        public enum ErrorCode : Int, ErrorRepresentable {
            case InvalidData = -500

            static var domain: String {
                return Haneke.Domain + ".disk"
            }
        }
        
    }
    
}

public class DiskFetcher<T : DataConvertible> : Fetcher<T> {
    
    let URL: NSURL
    var cancelled = false
    
    public init(URL: NSURL) {
        self.URL = URL
        super.init(key: URL.absoluteString!)
    }
    
    // MARK: Fetcher
    
    public override func fetch(failure fail : ((NSError?) -> ()), success succeed : (T) -> ()) {
        self.cancelled = false
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self] in
            if let strongSelf = self {
                strongSelf.privateFetch(fail, succeed)
            }
        })
    }
    
    public override func cancelFetch() {
        self.cancelled = true
    }
    
    // MARK: Private
    
    private func privateFetch(failure fail : ((NSError?) -> ()), success succeed : (T) -> ()) {
        if self.cancelled { return }
        
        var error: NSError?
        if let data = NSData(contentsOfURL: URL, options: .DataReadingMappedIfSafe, error: &error) {
            if self.cancelled { return }

            if let value = T(data: data) {
                dispatch_async(dispatch_get_main_queue()) {
                    if self.cancelled {
                        return
                    }
                    succeed(value)
                }
            } else {
                let localizedFormat = NSLocalizedString("Failed to convert value from data at %@", comment: "Error description")
                let description = String(format:localizedFormat, URL)
                let error = errorWithCode(Haneke.DiskFetcherGlobals.ErrorCode.InvalidData, description: description)
                dispatch_async(dispatch_get_main_queue()) {
                    fail(error)
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                fail(error)
            }
        }
    }
}
