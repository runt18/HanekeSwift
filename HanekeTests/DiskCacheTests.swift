//
//  DiskCacheTests.swift
//  Haneke
//
//  Created by Hermes Pique on 8/10/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit
import XCTest

private func setModificationDateForURL(URL: NSURL, date: NSDate) -> Bool {
    return URL.setResourceValue(date, forKey: NSURLContentModificationDateKey, error: nil)
}

private func modificationDateForURL(URL: NSURL) -> NSDate {
    URL.removeCachedResourceValueForKey(NSURLContentModificationDateKey)
    return URL.mapResourceValueForKey(NSURLContentModificationDateKey, failure: NSDate.distantFuture() as NSDate)
}

class DiskCacheTests: DiskTestCase {

    var sut : DiskCache!
    
    func setUpCache(capacity: Int = Int.max) {
        sut = DiskCache(name, capacity : capacity)
    }
    
    override func setUp() {
        super.setUp()
        setUpCache()
    }
    
    override func tearDown() {
        sut.removeAllData()
        super.tearDown()
    }
    
    func testInit() {
        XCTAssertEqual(sut.name, name)
        XCTAssertEqual(sut.size, 0)
    }
    
    func testInitWithOneFile() {
        let expectedSize = 8
        self.writeDataWithLength(expectedSize, directory: sut.cacheURL)
        
        setUpCache()
        
        sut.performBlockAndWait {
            XCTAssertEqual(self.sut.size, expectedSize)
        }
    }
    
    func testInitWithTwoFiles() {
        let lengths = [4, 7]
        self.writeDataWithLength(lengths[0], directory: sut.cacheURL)
        self.writeDataWithLength(lengths[1], directory: sut.cacheURL)
        
        setUpCache()
        
        sut.performBlockAndWait {
            XCTAssertEqual(self.sut.size, lengths.reduce(0, +))
        }
    }
    
    func testInitCapacityZeroOneExistingFile() {
        let URL = self.writeDataWithLength(1, directory: sut.cacheURL)
        
        setUpCache(capacity: 0)
        
        sut.performBlockAndWait {
            XCTAssertEqual(self.sut.size, 0)
            XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
            return
        }
    }
    
    func testInitCapacityZeroTwoExistingFiles() {
        let URL1 = self.writeDataWithLength(1, directory: sut.cacheURL)
        let URL2 = self.writeDataWithLength(2, directory: sut.cacheURL)
        
        setUpCache(capacity: 0)
        
        sut.performBlockAndWait {
            XCTAssertEqual(self.sut.size, 0)
            XCTAssertFalse(URL1.checkResourceIsReachableAndReturnError(nil))
            XCTAssertFalse(URL2.checkResourceIsReachableAndReturnError(nil))
        }
    }
    
    func testInitLeastRecentlyUsedExistingFileDeleted() {
        let URL1 = self.writeDataWithLength(1, directory: sut.cacheURL)
        let URL2 = self.writeDataWithLength(1, directory: sut.cacheURL)
        setModificationDateForURL(URL2, NSDate.distantPast() as NSDate)
        
        setUpCache(capacity: 1)
        
        sut.performBlockAndWait {
            XCTAssertEqual(self.sut.size, 1)
            XCTAssertTrue(URL1.checkResourceIsReachableAndReturnError(nil))
            XCTAssertFalse(URL2.checkResourceIsReachableAndReturnError(nil))
        }
    }
    
    func testCacheURL() {
        let cacheURL = DiskCache.baseURL(fileManager).URLByAppendingPathComponent(sut.name, isDirectory: true)
        XCTAssertEqual(sut.cacheURL, cacheURL)
        
        let (exists, isDir) = cacheURL.checkItemIsReachable()
        XCTAssertTrue(exists)
        XCTAssertTrue(isDir)
    }
    
    func testCacheDirEmptyName() {
        let sut = DiskCache("", capacity : Int.max)
        let cacheURL = DiskCache.baseURL(fileManager)
        XCTAssertEqual(sut.cacheURL, cacheURL)
        
        let (exists, isDir) = cacheURL.checkItemIsReachable()
        XCTAssertTrue(exists)
        XCTAssertTrue(isDir)
    }
    
    func testSetCapacity() {
        sut.setData(NSData.dataWithLength(1), key: self.name)
        
        sut.capacity = 0
        
        sut.performBlockAndWait {
            XCTAssertEqual(self.sut.size, 0)
        }
    }
    
    func testSetData() {
        let data = UIImagePNGRepresentation(UIImage.imageWithColor(UIColor.redColor()))
        let key = self.name
        let URL = sut.URLForKey(key)
        
        sut.setData(data, key: key)
        
        sut.performBlockAndWait {
            XCTAssertTrue(URL.checkResourceIsReachableAndReturnError(nil))
            let resultData = NSData(contentsOfURL: URL)
            XCTAssertEqual(resultData, data)
            XCTAssertEqual(self.sut.size, data.length)
        }
    }
    
    func testSetData_EscapedFilename() {
        let data = UIImagePNGRepresentation(UIImage.imageWithColor(UIColor.redColor()))
        let key = "http://haneke.io"
        let URL = sut.URLForKey(key)
        
        sut.setData(data, key: key)
        
        sut.performBlockAndWait {
            XCTAssertTrue(URL.checkResourceIsReachableAndReturnError(nil))
            let resultData = NSData(contentsOfURL: URL)
            XCTAssertEqual(resultData, data)
            XCTAssertEqual(self.sut.size, data.length)
        }
    }
    
    func testSetDataSizeGreaterThanZero() {
        let originalData = NSData.dataWithLength(5)
        let lengths = [5, 14]
        let keys = ["1", "2"]
        sut.setData(NSData.dataWithLength(lengths[0]), key: keys[0])
        
        sut.setData(NSData.dataWithLength(lengths[1]), key: keys[1])
        
        sut.performBlockAndWait {
            XCTAssertEqual(self.sut.size, lengths.reduce(0, combine: +))
        }
    }
    
    func testSetDataReplace() {
        let originalData = NSData.dataWithLength(5)
        let data = NSData.dataWithLength(14)
        let key = self.name
        let URL = sut.URLForKey(key)

        sut.setData(originalData, key: key)
        
        sut.setData(data, key: key)
        
        sut.performBlockAndWait {
            XCTAssertTrue(URL.checkResourceIsReachableAndReturnError(nil))
            let resultData = NSData(contentsOfURL: URL)
            XCTAssertEqual(resultData, data)
            XCTAssertEqual(self.sut.size, data.length)
        }
    }
    
    func testSetDataNil() {
        let key = self.name
        let URL = sut.URLForKey(key)
        
        sut.setData({ return nil }(), key: key)
        
        sut.performBlockAndWait {
            XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
            XCTAssertEqual(self.sut.size, 0)
        }
    }
    
    func testSetDataControlCapacity() {
        setUpCache(capacity: 0)
        let key = self.name
        let URL = sut.URLForKey(key)
        
        sut.setData(NSData.dataWithLength(1), key: key)
        
        sut.performBlockAndWait {
            XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
            XCTAssertEqual(self.sut.size, 0)
        }
    }
    
    func testFetchData() {
        let data = NSData.dataWithLength(14)
        let key = self.name
        sut.setData(data, key : key)
        
        let expectation = self.expectationWithDescription(self.name)
        
        sut.fetchData(key, {
            expectation.fulfill()
            XCTAssertEqual($0, data)
        })
        
        sut.performBlockAndWait {
            self.waitForExpectationsWithTimeout(0, nil)
        }
    }
    
    func testFetchData_Inexisting() {
        let key = self.name
        let expectation = self.expectationWithDescription(self.name)
        
        sut.fetchData(key,  success : { data in
            expectation.fulfill()
            XCTFail("Expected failure")
        }, failure : { errorOpt in
            expectation.fulfill()
            let error = errorOpt!
            XCTAssertEqual(error.code, NSFileReadNoSuchFileError)
        })
        
        sut.performBlockAndWait {
            self.waitForExpectationsWithTimeout(0, nil)
        }
    }
    
    func testFetchData_Inexisting_NilFailureBlock() {
        let key = self.name
        
        sut.fetchData(key, { data in
            XCTFail("Expected failure")
        })
        
        sut.performBlockAndWait {
            
        }
    }
    
    func testFetchData_UpdateAccessDate() {
        let data = NSData.dataWithLength(19)
        let key = self.name
        sut.setData(data, key : key)
        
        let URL = sut.URLForKey(key)
        
        sut.performBlockAndWait {
            let _ = setModificationDateForURL(URL, NSDate.distantPast() as NSDate)
        }
        
        let expectation = self.expectationWithDescription(self.name)
        
        // Preconditions
        sut.performBlockAndWait {
            XCTAssertEqual(modificationDateForURL(URL), NSDate.distantPast() as NSDate)
        }
        
        sut.fetchData(key, {
            expectation.fulfill()
            XCTAssertEqual($0, data)
        })
        
        sut.performBlockAndWait {
            self.waitForExpectationsWithTimeout(0, nil)
            let accessDate = modificationDateForURL(URL);
            let now = NSDate()
            let interval = accessDate.timeIntervalSinceDate(now)
            XCTAssertEqualWithAccuracy(interval, 0, 1)
        }
    }
    
    func testUpdateAccessDateFileInDisk() {
        let data = NSData.dataWithLength(10)
        let key = self.name
        sut.setData(data, key : key)

        let URL = sut.URLForKey(key)
        sut.performBlockAndWait {
            let _ = setModificationDateForURL(URL, NSDate.distantPast() as NSDate)
        }
        
        // Preconditions
        sut.performBlockAndWait {
            XCTAssertEqual(modificationDateForURL(URL), NSDate.distantPast() as NSDate)
        }
        
        sut.updateAccessDate(data, key: key)
        
        sut.performBlockAndWait {
            let accessDate = modificationDateForURL(URL)
            let now = NSDate()
            let interval = accessDate.timeIntervalSinceDate(now)
            XCTAssertEqualWithAccuracy(interval, 0, 1)
        }
    }
    
    func testUpdateAccessDateFileNotInDisk() {
        let image = UIImage.imageWithColor(UIColor.redColor())
        let key = self.name

        let URL = sut.URLForKey(key)
        
        // Preconditions
        sut.performBlockAndWait {
            XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
        }
        
        sut.updateAccessDate(image.hnk_data(), key: key)
        
        sut.performBlockAndWait {
            XCTAssertTrue(URL.checkResourceIsReachableAndReturnError(nil))
        }
    }
    
    func testRemoveDataTwoKeys() {
        let keys = ["1", "2"]
        let datas = [NSData.dataWithLength(5), NSData.dataWithLength(7)]
        sut.setData(datas[0], key: keys[0])
        sut.setData(datas[1], key: keys[1])

        sut.removeData(keys[1])
        
        sut.performBlockAndWait {
            let URL = self.sut.URLForKey(keys[1])
            XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
            XCTAssertEqual(self.sut.size, datas[0].length)
        }
    }
    
    func testRemoveDataExisting() {
        let key = self.name
        let data = UIImagePNGRepresentation(UIImage.imageWithColor(UIColor.redColor()))
        let URL = sut.URLForKey(key)
        sut.setData(data, key: key)
        
        sut.removeData(key)
        
        sut.performBlockAndWait {
            XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
            XCTAssertEqual(self.sut.size, 0)
        }
    }
    
    func testRemoveDataInexisting() {
        let key = self.name
        let URL = sut.URLForKey(key)
        
        // Preconditions
        XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
        
        sut.removeData(self.name)
    }
    
    func testRemoveAllData_Filled() {
        let key = self.name
        let data = NSData.dataWithLength(12)
        let URL = sut.URLForKey(key)
        sut.setData(data, key: key)
        
        sut.removeAllData()
        
        sut.performBlockAndWait {
            XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
            XCTAssertEqual(self.sut.size, 0)
        }
    }
    
    func testRemoveAllData_Empty() {
        let key = self.name
        let URL = sut.URLForKey(key)
        
        // Preconditions
        XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
        
        sut.removeData(self.name)
    }

}