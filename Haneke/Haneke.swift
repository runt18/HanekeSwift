//
//  Haneke.swift
//  Haneke
//
//  Created by Hermes Pique on 9/9/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol ErrorRepresentable: RawRepresentable {
    class var domain: String { get }
}

func errorWithCode<T: ErrorRepresentable where T.RawValue == Int>(code: T, description : String? = nil) -> NSError {
    var userInfo = [NSObject: AnyObject]()
    if let description = description {
        userInfo[NSLocalizedDescriptionKey] = description
    }
    return NSError(domain: code.dynamicType.domain, code: code.rawValue, userInfo: userInfo)
}

func ==(lhs: NSError?, rhs: (domain: String, code: Int)) -> Bool {
    if let error = lhs {
        if error.domain != rhs.domain { return false }
        if error.code != rhs.code { return false }
        return true
    }
    return false
}

func ==<T: ErrorRepresentable where T.RawValue == Int>(lhs: NSError?, rhs: T) -> Bool {
    return lhs == (rhs.dynamicType.domain, rhs.rawValue)
}

public struct Haneke {
    
    internal static let Domain = "io.haneke"
    
    public static var sharedImageCache : Cache<UIImage> {
        struct Static {
            static let name = "shared-images"
            static let cache = Cache<UIImage>(name: name)
        }
        return Static.cache
    }
    
    public static var sharedDataCache : Cache<NSData> {
        struct Static {
            static let name = "shared-data"
            static let cache = Cache<NSData>(name: name)
        }
        return Static.cache
    }
    
    public static var sharedStringCache : Cache<String> {
        struct Static {
            static let name = "shared-strings"
            static let cache = Cache<String>(name: name)
        }
        return Static.cache
    }
    
    public static var sharedJSONCache : Cache<JSON> {
    struct Static {
        static let name = "shared-json"
        static let cache = Cache<JSON>(name: name)
        }
        return Static.cache
    }
    
    internal static let CacheItem: String! = {
        return UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, "hnk", kUTTypeData).takeRetainedValue() as String!
    }()
    
}

struct Log {
    
    static func error(message : String, _ error : NSError? = nil) {
        if let error = error {
            NSLog("%@ with error %@", message, error);
        } else {
            NSLog("%@", message)
        }
    }
    
}
