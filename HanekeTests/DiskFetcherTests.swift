//
//  DiskFetcherTests.swift
//  Haneke
//
//  Created by Joan Romano on 21/09/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit
import XCTest

class DiskFetcherTests: DiskTestCase {
    
    var sut : DiskFetcher<UIImage>!
    var URL: NSURL!

    override func setUp() {
        super.setUp()
        URL = self.uniqueURL()
        sut = DiskFetcher(URL: URL)
    }
    
    func testInit() {
        XCTAssertEqual(sut.URL, URL)
    }
    
    func testKey() {
        XCTAssertEqual(sut.key, URL.absoluteString!)
    }
    
    func testFetchImage_Success() {
        let image = UIImage.imageWithColor(UIColor.greenColor(), CGSizeMake(10, 20))
        let data = UIImagePNGRepresentation(image)
        data.writeToURL(sut.URL, options: .DataWritingAtomic, error: nil)
        
        let expectation = expectationWithDescription(name)
        
        sut.fetch(failure: { _ in
            XCTFail("Expected to succeed")
            expectation.fulfill()
        }) {
            let result = $0 as UIImage
            XCTAssertTrue(result.isEqualPixelByPixel(image))
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testFetchImage_Failure_NSFileReadNoSuchFileError() {
        let expectation = expectationWithDescription(name)
        
        sut.fetch(failure: { error in
            XCTAssertTrue(error == (NSCocoaErrorDomain, NSFileReadNoSuchFileError))
            expectation.fulfill()
        }) { _ in
            XCTFail("Expected to fail")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testFetchImage_Failure_HNKDiskEntityInvalidDataError() {
        let data = NSData()
        data.writeToURL(sut.URL, options: .DataWritingAtomic, error: nil)
        
        let expectation = expectationWithDescription(name)
        
        sut.fetch(failure: { error in
            XCTAssertTrue(error == Haneke.DiskFetcherGlobals.ErrorCode.InvalidData)
            XCTAssertNotNil(error?.localizedDescription)
            expectation.fulfill()
        }) { _ in
            XCTFail("Expected to fail")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testCancelFetch() {
        let image = UIImage.imageWithColor(UIColor.greenColor(), CGSizeMake(10, 20))
        let data = UIImagePNGRepresentation(image)
        data.writeToURL(directoryURL, options: .DataWritingAtomic, error: nil)
        sut.fetch(failure: { _ in
            XCTFail("Unexpected failure")
        }) { _ in
            XCTFail("Unexpected success")
        }
        
        sut.cancelFetch()
        
        self.waitFor(0.1)
    }
    
    func testCancelFetch_NoFetch() {
        sut.cancelFetch()
    }
    
    // MARK: Cache extension
    
    func testCacheFetch_Success() {
        let data = NSData.dataWithLength(1)
        let URL = writeData(data)
        let expectation = expectationWithDescription(name)
        let cache = Cache<NSData>(name: name)
        
        cache.fetch(URL: URL, failure: {_ in
            XCTFail("expected success")
            expectation.fulfill()
        }) {
            XCTAssertEqual($0, data)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(1, handler: nil)
        
        cache.removeAll()
    }
    
    func testCacheFetch_Failure() {
        let URL = self.directoryURL.URLByAppendingPathComponent(name, isDirectory: false)
        let expectation = expectationWithDescription(name)
        let cache = Cache<NSData>(name: name)
        
        cache.fetch(URL: URL, failure: {_ in
            expectation.fulfill()
        }) { _ in
            XCTFail("expected success")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(1, handler: nil)
        
        cache.removeAll()
    }
    
    func testCacheFetch_WithFormat() {
        let data = NSData.dataWithLength(1)
        let URL = writeData(data)
        let expectation = expectationWithDescription(name)
        let cache = Cache<NSData>(name: name)
        let format = Format<NSData>(name: name)
        cache.addFormat(format)
        
        cache.fetch(URL: URL, formatName: format.name, failure: {_ in
            XCTFail("expected success")
            expectation.fulfill()
        }) {
            XCTAssertEqual($0, data)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(1, handler: nil)
        
        cache.removeAll()
    }
}
