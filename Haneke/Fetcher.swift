//
//  Fetcher.swift
//  Haneke
//
//  Created by Hermes Pique on 9/9/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit
import Swift

public protocol Fetcher {
    typealias Fetched
    
    var key: String { get }
    
    func fetchWithSuccess(success doSuccess : (Fetched) -> (), failure doFailure : ((NSError?) -> ()))
    func cancelFetch()
}

public struct SimpleFetcher<T : DataConvertible> : Fetcher {
    typealias Fetched = T.Result

    public let key: String
    let getThing : () -> T.Result
    
    init(key : String, thing getThing : @autoclosure () -> T.Result) {
        self.getThing = getThing
        self.key = key
    }
    
    public func fetchWithSuccess(success doSuccess : (T.Result) -> (), failure doFailure : ((NSError?) -> ())) {
        let thing = getThing()
        doSuccess(thing)
    }
    
    public func cancelFetch() {}
    
}
