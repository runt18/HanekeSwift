//
//  NSFileManager+Haneke.swift
//  Haneke
//
//  Created by Hermes Pique on 8/26/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import Foundation

extension NSFileManager {
    public func enumerateContentsOfDirectoryAtURL(URL: NSURL) -> SequenceOf<NSURL> {
        var error : NSError?
        if let contents = self.contentsOfDirectoryAtURL(URL, includingPropertiesForKeys: nil, options: nil, error: &error) as? [NSURL] {
            return SequenceOf(contents)
        }
        println("Failed to list directory with error \(error)")
        return SequenceOf([])
    }
    
    public func enumerateContentsOfDirectoryAtURL<T : Comparable>(URL: NSURL, byProperty property: String, isOrderedBefore comparator: (T, T) -> Bool) -> SequenceOf<NSURL> {
        var error : NSError?
        if let contents = self.contentsOfDirectoryAtURL(URL, includingPropertiesForKeys: [property], options: nil, error: &error) as? [NSURL] {
            let sortedContents = contents.sorted({(URL1 : NSURL, URL2 : NSURL) -> Bool in
                var value1 : AnyObject?
                if !URL1.getResourceValue(&value1, forKey: property, error: nil) { return true }
                var value2 : AnyObject?
                if !URL2.getResourceValue(&value2, forKey: property, error: nil) { return false }
                let comp1 = value1 as? T
                let comp2 = value2 as? T
                if comp1 == nil || comp2 == nil {
                    return false
                }
                return comparator(comp1!, comp2!)
            })
            return SequenceOf(sortedContents)
        }
        println("Failed to list directory with error \(error)")
        return SequenceOf([])
    }
}
