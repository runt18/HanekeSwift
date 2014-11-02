//
//  NSURL+Haneke.swift
//  Haneke
//
//  Created by Zachary Waldowski on 9/23/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import Foundation

public enum Result<T: AnyObject> {
    case None
    case Some(T)
    case Error(NSError)
}

public extension NSURL {

    public func resourceValue<T: AnyObject>(forKey key: String) -> Result<T> {
        var value: AnyObject?
        var error: NSError?
        if getResourceValue(&value, forKey: key, error: &error) {
            if let ret = value as? T {
                return Result.Some(ret)
            }
            return Result.None
        }
        return Result.Error(error!)
    }

    public func mapResourceValue<T: AnyObject, U>(forKey key: String, success: (T) -> U, failure: @autoclosure () -> U) -> U {
        var ret: U!
        let result: Result<T> = resourceValue(forKey: key)
        switch result {
        case .Some(let value):
            return success(value)
        default:
            return failure()
        }
    }

    public func mapResourceValue<T: AnyObject>(forKey key: String, failure: @autoclosure () -> T) -> T {
        return mapResourceValue(forKey: key, success: { (value: T) in
            return value
        }, failure: failure)
    }

    public func checkItemIsReachable() -> (exists: Bool, isDirectory: Bool) {
        if checkResourceIsReachableAndReturnError(nil) {
            return (true, mapResourceValue(forKey: NSURLIsDirectoryKey, success: { (value: NSNumber) in
                return value.boolValue
            }, failure: false))
        }
        return (false, false)
    }

}
