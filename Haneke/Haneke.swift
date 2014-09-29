//
//  Haneke.swift
//  Haneke
//
//  Created by Hermes Pique on 9/9/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit
import Swift

protocol ErrorRepresentable: RawRepresentable {
    class var domain: String { get }
}

func errorWithCode<T: ErrorRepresentable where T.Raw == Int>(code: T, #description : String) -> NSError {
    let userInfo = [NSLocalizedDescriptionKey: description]
    return NSError(domain: code.dynamicType.domain, code: code.toRaw(), userInfo: userInfo)
}

func errorIs<T: ErrorRepresentable where T.Raw == Int>(error: NSError?, #code: T) -> Bool {
    if let error = error {
        if error.domain != code.dynamicType.domain { return false }
        if error.code != code.toRaw() { return false }
        return true
    }
    return false
}

public struct Haneke {
    
    public static let Domain = "io.haneke"
    
    private struct Shared {
        private static let imageCache = Cache<UIImage>("shared-images")
        private static let dataCache = Cache<NSData>("shared-data")
        private static let stringCache = Cache<String>("shared-strings")
    }
    
    public static var sharedImageCache : Cache<UIImage> {
        return Shared.imageCache
    }
    
    public static var sharedDataCache : Cache<NSData> {
        return Shared.dataCache
    }
    
    public static var sharedStringCache : Cache<String> {
        return Shared.stringCache
    }
    
}
