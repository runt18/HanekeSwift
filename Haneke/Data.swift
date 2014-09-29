//
//  Data.swift
//  Haneke
//
//  Created by Hermes Pique on 9/19/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit
import Swift

// See: http://stackoverflow.com/questions/25922152/not-identical-to-self
public protocol DataConvertible {
    typealias Result
    
    class func convertFromData(data: NSData) -> Result?
    
    func asData() -> NSData!
}

public protocol Decompressible: class {
    
    func asDecompressedValue() -> Self
    
}

extension UIImage: DataConvertible {
    
    public typealias Result = UIImage
    
    public class func convertFromData(data:NSData) -> UIImage? {
        let image : UIImage? = UIImage(data: data) // Workaround for initializer that might return nil
        return image
    }
    
    public func asData() -> NSData! {
        return self.hnk_data()
    }
    
}

extension String: DataConvertible {
    
    public typealias Result = String
    
    public static func convertFromData(data:NSData) -> Result? {
        var string : String? = NSString(data: data, encoding: NSUTF8StringEncoding) // Workaround for initializer that might return nil
        return string
    }
    
    public func asData() -> NSData! {
        return self.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
}

extension NSData: DataConvertible {
    
    public typealias Result = NSData
    
    public class func convertFromData(data:NSData) -> Result? {
        return data
    }
    
    public func asData() -> NSData! {
        return self
    }
    
}
