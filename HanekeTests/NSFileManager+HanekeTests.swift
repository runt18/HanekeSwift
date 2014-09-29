//
//  NSFileManager+HanekeTests.swift
//  Haneke
//
//  Created by Hermes Pique on 8/26/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import XCTest

public func <(lhs: NSURL, rhs: NSURL) -> Bool {
    let lhsPath = lhs.URLByStandardizingPath?.path ?? ""
    let rhsPath = rhs.URLByStandardizingPath?.path ?? ""
    return lhsPath < rhsPath
}

public func ==(lhs: NSURL, rhs: NSURL) -> Bool {
    let lhsPath = lhs.URLByStandardizingPath?.path ?? ""
    let rhsPath = rhs.URLByStandardizingPath?.path ?? ""
    return lhsPath == rhsPath
}

extension NSURL: Comparable, Equatable {}

public func <(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
}

public func ==(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedSame
}

extension NSNumber: Comparable, Equatable {}

class NSFileManager_HanekeTests: DiskTestCase {
    func testEnumerateDirectoryAtEmpty() {
        for url in fileManager.enumerateContentsOfDirectoryAtURL(directoryURL) {
            XCTFail()
        }
    }
    
    func testEnumerateDirectoryStop() {
        let _ = [self.writeDataWithLength(1), self.writeDataWithLength(2)]
        var count = 0
        for url in fileManager.enumerateContentsOfDirectoryAtURL(directoryURL, byProperty: NSURLNameKey, isOrderedBefore: { (a: String, b: String) in
            a < b
        }) {
            count++
            break
        }
        XCTAssertEqual(count, 1)
    }
    
    func testEnumerateDirectory() {
        let URLs = [self.writeDataWithLength(1), self.writeDataWithLength(2)].sorted(<)
        var resultURLs = [NSURL]()
        var indexes = [Int]()
        
        for (index, URL) in enumerate(fileManager.enumerateContentsOfDirectoryAtURL(directoryURL, byProperty: NSURLNameKey, isOrderedBefore: { (a: String, b: String) -> Bool in
            a < b
        })) {
            resultURLs.append(URL)
            indexes.append(index)
        }
        
        XCTAssertEqual(resultURLs.count, 2)
        XCTAssertEqual(resultURLs, URLs)
        XCTAssertEqual(indexes[0], 0)
        XCTAssertEqual(indexes[1], 1)
    }
    
    func testEnumerateDirectoryFileSize() {
        let URLs = [self.writeDataWithLength(1), self.writeDataWithLength(2)]
        var resultURLs = [NSURL]()
        
        for URL in fileManager.enumerateContentsOfDirectoryAtURL(directoryURL, byProperty: NSURLFileSizeKey, isOrderedBefore: { (a: NSNumber, b: NSNumber) in
            a.compare(b) == NSComparisonResult.OrderedAscending
        }) {
            resultURLs.append(URL)
        }
        
        XCTAssertEqual(resultURLs.count, 2)
        XCTAssertEqual(resultURLs, URLs)
    }
    
    func testEnumerateDirectoryModificationDate() {
        let URLs = [self.writeDataWithLength(1), self.writeDataWithLength(2)]
        URLs[0].setResourceValue(NSDate.distantPast(), forKey: NSURLContentModificationDateKey, error: nil)
        
        var resultURLs = [NSURL]()
        
        for URL in fileManager.enumerateContentsOfDirectoryAtURL(directoryURL, byProperty: NSURLContentModificationDateKey, isOrderedBefore: { (a: NSDate, b: NSDate) in
            a.compare(b) == NSComparisonResult.OrderedAscending
        }) {
            resultURLs.append(URL)
        }
        
        XCTAssertEqual(resultURLs.count, 2)
        XCTAssertEqual(resultURLs, URLs)
    }
    
}

