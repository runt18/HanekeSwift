//
//  NSFileManager+Haneke.swift
//  Haneke
//
//  Created by Hermes Pique on 8/26/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import Foundation

public func sorted<C: SequenceType, T: AnyObject where C.Generator.Element == NSURL>(source: C, byResourceValue property: String, isOrderedBefore comparator: ((T, T) -> Bool)) -> [NSURL] {
    return sorted(source) { (URL1: NSURL, URL2: NSURL) -> Bool in
        let value1: Result<T> = URL1.resourceValue(forKey: property)
        let value2: Result<T> = URL2.resourceValue(forKey: property)

        switch (value1, value2) {
        case (.Some(let box1), .Some(let box2)):
            return comparator(box1, box2)
        default:
            return false
        }
    }
}

public extension NSFileManager {

    public struct Utilities {

        public static let StringsOrderedBefore = { (a: String, b: String) -> Bool in
            return a < b
        }

        public static let DatesOrderedBefore = { (a: NSDate, b: NSDate) -> Bool in
            return a.compare(b) == NSComparisonResult.OrderedAscending
        }

        public static let DatesOrderedAfter = { (a: NSDate, b: NSDate) -> Bool in
            return a.compare(b) == NSComparisonResult.OrderedDescending
        }

        public static let NumbersOrderedBefore = { (a: NSNumber, b: NSNumber) -> Bool in
            return a.compare(b) == NSComparisonResult.OrderedAscending
        }

    }

    func contents(directoryAtURL URL: NSURL, includingProperties: [String]?) -> SequenceOf<NSURL> {
        var error : NSError?
        if let contents = contentsOfDirectoryAtURL(URL, includingPropertiesForKeys: nil, options: nil, error: &error) as? [NSURL] {
            return SequenceOf(contents)
        }
        println("Failed to list directory with error \(error)")
        return SequenceOf([])
    }

    func contents<T: AnyObject>(directoryAtURL URL: NSURL, sortedByResourceValue property: String, isOrderedBefore comparator: (T, T) -> Bool) -> [NSURL] {
        let unsorted = contents(directoryAtURL: URL, includingProperties: [ property ])
        return sorted(unsorted, byResourceValue: property, isOrderedBefore: comparator)
    }

}
