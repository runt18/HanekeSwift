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

extension NSFileManager {

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

    func enumerateContentsOfDirectoryAtPath(path : String, orderedByProperty property : String, ascending : Bool, usingBlock block : (NSURL, Int, inout Bool) -> Void ) {

        let directoryURL = NSURL(fileURLWithPath: path)
        if directoryURL == nil { return }
        var error : NSError?
        if let contents = self.contentsOfDirectoryAtURL(directoryURL!, includingPropertiesForKeys: [property], options: NSDirectoryEnumerationOptions.allZeros, error: &error) as? [NSURL] {

            let sortedContents = contents.sorted({(URL1 : NSURL, URL2 : NSURL) -> Bool in

                // Maybe there's a better way to do this. See: http://stackoverflow.com/questions/25502914/comparing-anyobject-in-swift

                var value1 : AnyObject?
                if !URL1.getResourceValue(&value1, forKey: property, error: nil) { return true }
                var value2 : AnyObject?
                if !URL2.getResourceValue(&value2, forKey: property, error: nil) { return false }


                if let string1 = value1 as? String {
                    if let string2 = value2 as? String {
                        return ascending ? string1 < string2 : string2 < string1
                    }
                }
                if let date1 = value1 as? NSDate {
                    if let date2 = value2 as? NSDate {
                        return ascending ? date1 < date2 : date2 < date1
                    }
                }

                if let number1 = value1 as? NSNumber {
                    if let number2 = value2 as? NSNumber {
                        return ascending ? number1 < number2 : number2 < number1
                    }
                }

                return false
            })

            for (i, v) in enumerate(sortedContents) {
                var stop : Bool = false
                block(v, i, &stop)
                if stop { break }
            }
        } else {
            Log.error("Failed to list directory", error)
        }
    }

}

func < (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
}

func < (lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
}
