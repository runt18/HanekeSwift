//
//  NSFileManager+HanekeTests.swift
//  Haneke
//
//  Created by Hermes Pique on 8/26/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import XCTest
import Haneke

class NSFileManager_HanekeTests: DiskTestCase {
    
    func testEnumerateDirectoryEmpty() {
        for URL in fileManager.contents(directoryAtURL: directoryURL, includingProperties: nil) {
            XCTFail()
        }
    }
    
    func testEnumerateDirectoryStop() {
        let URLs = [ writeDataWithLength(1), writeDataWithLength(2) ]
        var count = 0
        
        for itemURL in fileManager.contents(directoryAtURL: directoryURL, includingProperties: nil) {
            count++
            break
        }
        
        XCTAssertEqual(count, 1)
    }
    
    func testEnumerateDirectoryNameAscending() {
        let URLs = [ writeDataWithLength(1), writeDataWithLength(2) ].sorted { lhs, rhs in
            return lhs.lastPathComponent < rhs.lastPathComponent
        }
        
        var results = [NSURL]()
        var indexes = [Int]()
        
        for (index, URL) in enumerate(fileManager.contents(directoryAtURL: directoryURL, includingProperties: nil)) {
            results.append(URL)
            indexes.append(index)
        }
        
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results, URLs)
        XCTAssertEqual(indexes[0], 0)
        XCTAssertEqual(indexes[1], 1)
    }
    
    func testEnumerateDirectoryFileSizeAscending() {
        let URLs = [ writeDataWithLength(1), writeDataWithLength(2) ]
        let results = [NSURL](fileManager.contents(directoryAtURL: directoryURL, sortedByResourceValue: NSURLFileSizeKey, isOrderedBefore: NSFileManager.Utilities.NumbersOrderedBefore))
        
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results, URLs)
    }
    
    func testEnumerateDirectoryModificationDateAscending() {
        let URLs = [ writeDataWithLength(1), writeDataWithLength(2) ]
        let results = [NSURL](fileManager.contents(directoryAtURL: directoryURL, sortedByResourceValue: NSURLContentModificationDateKey, isOrderedBefore: NSFileManager.Utilities.DatesOrderedBefore))

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results, URLs)
    }
    
}

