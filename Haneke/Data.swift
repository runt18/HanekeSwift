//
//  Data.swift
//  Haneke
//
//  Created by Hermes Pique on 9/19/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit

public protocol DataConvertible {
    init?(data: NSData)
    var dataValue: NSData! { get }
}

extension UIImage: DataConvertible {
    
    public var dataValue: NSData! {
        return self.hnk_data()
    }
    
}

extension String : DataConvertible {
    
    public init?(data: NSData) {
        let buf = UnsafeBufferPointer(start: UnsafePointer<Byte>(data.bytes), count: data.length)
        self.init(bytes: buf, encoding: NSUTF8StringEncoding)
    }
    
    public var dataValue: NSData! {
        return self.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
}

extension NSData: DataConvertible {
    
    public var dataValue: NSData! {
        return self
    }
    
}

public enum JSON {
    case Dictionary([String:AnyObject])
    case Array([AnyObject])
    
    public var array : [AnyObject]! {
        switch (self) {
        case .Dictionary(let _):
            return nil
        case .Array(let array):
            return array
        }
    }
    
    public var dictionary : [String:AnyObject]! {
        switch (self) {
        case .Dictionary(let dictionary):
            return dictionary
        case .Array(let _):
            return nil
        }
    }
    
}

extension JSON: DataConvertible {

    public init?(data: NSData) {
        var error: NSError?
        let object: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error)

        switch (object) {
        case let dictionary as [String: AnyObject]:
            self = .Dictionary(dictionary)
        case let array as [AnyObject]:
            self = .Array(array)
        default:
            if let error = error {
                println("Invalid JSON data with error \(error.localizedDescription)")
            }
            return nil
        }
    }

    public var dataValue: NSData! {
        switch (self) {
        case .Dictionary(let dictionary):
            return NSJSONSerialization.dataWithJSONObject(dictionary, options: nil, error: nil)
        case .Array(let array):
            return NSJSONSerialization.dataWithJSONObject(array, options: nil, error: nil)
        }
    }

}
