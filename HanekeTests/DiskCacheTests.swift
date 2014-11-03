//
//  DiskCacheTests.swift
//  Haneke
//
//  Created by Hermes Pique on 8/10/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit
import XCTest


private func accessDateForURL(URL: NSURL) -> NSDate {
    URL.removeCachedResourceValueForKey(NSURLContentAccessDateKey)
    return URL.mapResourceValue(forKey: NSURLContentAccessDateKey, failure: NSDate.distantFuture() as NSDate)
}

class DiskCacheTests: DiskTestCase {
    
    override func tearDown() {
        sut.removeAllData()
        super.tearDown()
    }
    
    lazy var sut : DiskCache! = {
        return DiskCache(URL: self.directoryURL, fileManager: self.fileManager)
    }()

    func reloadCache(capacity: UInt64 = UINT64_MAX) {
        sut = DiskCache(URL: directoryURL, capacity: capacity, fileManager: fileManager)
    }

    // MARK: baseURL

    func testBaseURL() {
        let cachesPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        let basePath = cachesPath.stringByAppendingPathComponent(Haneke.Domain)
        let expectedBaseURL = NSURL.fileURLWithPath(basePath, isDirectory: true)
        XCTAssertEqual(DiskCache.baseURL(fileManager: fileManager), expectedBaseURL!)
    }
    
    // MARK: cacheURL

    func testCacheURL() {
        let expectedCacheURL = DiskCache.baseURL(fileManager: fileManager).URLByAppendingPathComponent(name, isDirectory: true)
        let cacheURL = DiskCache.cacheURL(fileManager: fileManager, name: name)
        XCTAssertEqual(cacheURL, expectedCacheURL)
    }

    // MARK: -

    func testInit() {
        XCTAssertEqual(sut.URL, directoryURL)
        XCTAssertEqual(Int(sut.size), 0)
    }
    
    func testInitWithOneFile() {
        let expectedSize = 8
        _ = writeDataWithLength(expectedSize, inDirectory: directoryURL)
        
        reloadCache()
        
        sut.performAndWait {
            XCTAssertEqual(self.sut.size, UInt64(expectedSize))
        }
    }
    
    func testInitWithTwoFiles() {
        let lengths = [4, 7]
        _ = writeDataWithLength(lengths[0], inDirectory: directoryURL)
        _ = writeDataWithLength(lengths[1], inDirectory: directoryURL)
        
        reloadCache()
        
        sut.performAndWait {
            XCTAssertEqual(self.sut.size, UInt64(lengths.reduce(0, +)))
        }
    }
    
    func testInitCapacityZeroOneExistingFile() {
        let URL = writeDataWithLength(1, inDirectory: directoryURL)
        
        reloadCache(capacity: 0)
        
        sut.performAndWait {
            XCTAssertEqual(Int(self.sut.size), 0)
            XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
        }
    }
    
    func testInitCapacityZeroTwoExistingFiles() {
        let URL1 = writeDataWithLength(1, inDirectory: directoryURL)
        let URL2 = writeDataWithLength(2, inDirectory: directoryURL)
        
        reloadCache(capacity: 0)
        
        sut.performAndWait {
            XCTAssertEqual(Int(self.sut.size), 0)
            XCTAssertFalse(URL1.checkResourceIsReachableAndReturnError(nil))
            XCTAssertFalse(URL2.checkResourceIsReachableAndReturnError(nil))
        }
    }
    
    func testInitLeastRecentlyUsedExistingFileDeleted() {
        let key1 = "1"
        let key2 = "2"

        sut.setData(NSData.dataWithLength(1), key: key1)
        sut.setData(NSData.dataWithLength(1), key: key2)

        let expectation = self.expectationWithDescription(name)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_global_queue(0, 0)) {
            self.sut.fetchData(key1, success: { _ in })
            self.sut.capacity = 1
            self.sut.performAndWait {
                expectation.fulfill()
                XCTAssertEqual(self.sut.size, UInt64(1))
                XCTAssertTrue(self.sut.URLForKey(key1).checkResourceIsReachableAndReturnError(nil))
                XCTAssertFalse(self.sut.URLForKey(key2).checkResourceIsReachableAndReturnError(nil))
            }
        }

        self.waitForExpectationsWithTimeout(3, nil)
    }
    
    func testSetCapacity() {
        sut.setData(NSData.dataWithLength(1), key: name)
        
        sut.capacity = 0
        
        sut.performAndWait {
            XCTAssertEqual(Int(self.sut.size), 0)
        }
    }
    
    func testSetData() {
        let data = UIImagePNGRepresentation(UIImage.imageWithColor(UIColor.redColor()))
        let URL = sut.URLForKey(name)
        
        sut.setData(data, key: name)
        
        sut.performAndWait {
            XCTAssertTrue(URL.checkResourceIsReachableAndReturnError(nil))
            let resultData = NSData(contentsOfURL: URL)!
            XCTAssertEqual(resultData, data)
            XCTAssertEqual(self.sut.size, UInt64(data.length))
        }
    }
    
    func testSetData_WithKeyIncludingSpecialCharacters() {
        let sut = self.sut!
        let data = UIImagePNGRepresentation(UIImage.imageWithColor(UIColor.redColor()))
        let key = "http://haneke.io"
        let URL = sut.URLForKey(key)
        
        sut.setData(data, key: key)
        
        sut.performAndWait {
            XCTAssertTrue(URL.checkResourceIsReachableAndReturnError(nil))
            let resultData = NSData(contentsOfURL: URL)!
            XCTAssertEqual(resultData, data)
            XCTAssertEqual(sut.size, UInt64(data.length))
        }
    }
    
    func testSetData_WithLongKey() {
        let sut = self.sut!
        let data = NSData.dataWithLength(10)
        let key = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam pretium id nibh a pulvinar. Integer id ex in tellus egestas placerat. Praesent ultricies libero ligula, et convallis ligula imperdiet eu. Sed gravida, turpis sed vulputate feugiat, metus nisl scelerisque diam, ac aliquet metus nisi rutrum ipsum. Nulla vulputate pretium dolor, a pellentesque nulla. Nunc pellentesque tortor porttitor, sollicitudin leo in, sollicitudin ligula. Cras malesuada orci at neque interdum elementum. Integer sed sagittis diam. Mauris non elit sed augue consequat feugiat. Nullam volutpat tortor eget tempus pretium. Sed pharetra sem vitae diam hendrerit, sit amet dapibus arcu interdum. Fusce egestas quam libero, ut efficitur turpis placerat eu. Sed velit sapien, aliquam sit amet ultricies a, bibendum ac nibh. Maecenas imperdiet, quam quis tincidunt sollicitudin, nunc tellus ornare ipsum, nec rhoncus nunc nisi a lacus."
        let URL = sut.URLForKey(key)
        
        sut.setData(data, key: key)
        
        sut.performAndWait {
            XCTAssertTrue(URL.checkResourceIsReachableAndReturnError(nil))
            let resultData = NSData(contentsOfURL: URL)!
            XCTAssertEqual(resultData, data)
            XCTAssertEqual(sut.size, UInt64(data.length))
        }
    }
    
    func testSetDataSizeGreaterThanZero() {
        let originalData = NSData.dataWithLength(5)
        let lengths = [5, 14]
        let keys = ["1", "2"]
        sut.setData(NSData.dataWithLength(lengths[0]), key: keys[0])
        
        sut.setData(NSData.dataWithLength(lengths[1]), key: keys[1])
        
        sut.performAndWait {
            XCTAssertEqual(self.sut.size, UInt64(lengths.reduce(0, combine: +)))
        }
    }
    
    func testSetDataReplace() {
        let originalData = NSData.dataWithLength(5)
        let data = NSData.dataWithLength(14)
        let URL = sut.URLForKey(name)
        sut.setData(originalData, key: name)
        
        sut.setData(data, key: name)
        
        sut.performAndWait {
            XCTAssertTrue(URL.checkResourceIsReachableAndReturnError(nil))
            let resultData = NSData(contentsOfURL: URL)!
            XCTAssertEqual(resultData, data)
            XCTAssertEqual(self.sut.size, UInt64(data.length))
        }
    }
    
    func testSetDataNil() {
        let key = self.name
        let URL = sut.URLForKey(name)
        
        sut.setData({ return nil }(), key: name)
        
        sut.performAndWait {
            XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
            XCTAssertEqual(Int(self.sut.size), 0)
        }
    }
    
    func testSetDataControlCapacity() {
        reloadCache(capacity: 0)
        let URL = sut.URLForKey(name)
        
        sut.setData(NSData.dataWithLength(1), key: name)
        
        sut.performAndWait {
            XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
            XCTAssertEqual(Int(self.sut.size), 0)
        }
    }
    
    func testFetchData() {
        let data = NSData.dataWithLength(14)
        let key = self.name
        sut.setData(data, key : key)
        
        let expectation = self.expectationWithDescription(self.name)
        
        sut.fetchData(key, success: {
            expectation.fulfill()
            XCTAssertEqual($0, data)
        })
        
        sut.performAndWait {
            self.waitForExpectationsWithTimeout(0, nil)
        }
    }
    
    func testFetchData_Inexisting() {
        let key = self.name
        let expectation = self.expectationWithDescription(self.name)
        
        sut.fetchData(key, failure : { error in
            XCTAssertTrue(error == (NSCocoaErrorDomain, NSFileReadNoSuchFileError))
            expectation.fulfill()
        }) { data in
            XCTFail("Expected failure")
            expectation.fulfill()
        }
        
        sut.performAndWait {
            self.waitForExpectationsWithTimeout(0, nil)
        }
    }
    
    func testFetchData_Inexisting_NilFailureBlock() {
        let key = self.name
        
        sut.fetchData(key, success: { _ in
            XCTFail("Expected failure")
        })
        
        sut.performAndWait {}
    }
    
    func testFetchData_UpdateAccessDate() {
        let data = NSData.dataWithLength(19)
        let URL = sut.URLForKey(name)

        sut.setData(data, key: name)

        let expectation = self.expectationWithDescription(name)
        
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_global_queue(0, 0)) {
            self.sut.fetchData(self.name, success: { _ in })

            self.sut.performAndWait {
                expectation.fulfill()

                let accessDate = accessDateForURL(URL)
                let now = NSDate()
                let interval = accessDate.timeIntervalSinceDate(now)
                XCTAssertEqualWithAccuracy(interval, 0, 1)
            }
        }
        
        self.waitForExpectationsWithTimeout(0.5, nil)
    }
    
    func testUpdateAccessDateFile() {
        let data = NSData.dataWithLength(10)
        let URL = sut.URLForKey(name)
        
        sut.updateAccessDate(data, key: name)
        
        sut.performAndWait {
            let accessDate = accessDateForURL(URL)
            let now = NSDate()
            let interval = accessDate.timeIntervalSinceDate(now)
            XCTAssertEqualWithAccuracy(interval, 0, 1)
        }
    }
    
    func testUpdateAccessDateFileNotInDisk() {
        let image = UIImage.imageWithColor(UIColor.redColor())
        let URL = sut.URLForKey(name)
        
        // Preconditions
        sut.performAndWait {
            XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
        }
        
        sut.updateAccessDate(image.hnk_data(), key: name)
        
        sut.performAndWait {
            XCTAssertTrue(URL.checkResourceIsReachableAndReturnError(nil))
        }
    }
    
    func testRemoveDataTwoKeys() {
        let keys = ["1", "2"]
        let datas = [NSData.dataWithLength(5), NSData.dataWithLength(7)]
        sut.setData(datas[0], key: keys[0])
        sut.setData(datas[1], key: keys[1])

        sut.removeData(keys[1])
        
        sut.performAndWait {
            let URL = self.sut.URLForKey(keys[1])
            XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
            XCTAssertEqual(self.sut.size, UInt64(datas[0].length))
        }
    }
    
    func testRemoveDataExisting() {
        let data = UIImagePNGRepresentation(UIImage.imageWithColor(UIColor.redColor()))
        let URL = sut.URLForKey(name)
        sut.setData(data, key: name)
        
        sut.removeData(name)
        
        sut.performAndWait {
            XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
            XCTAssertEqual(Int(self.sut.size), 0)
        }
    }
    
    func testRemoveDataInexisting() {
        let URL = sut.URLForKey(name)
        
        // Preconditions
        XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
        
        sut.removeData(name)
    }
    
    func testRemoveAllData_Filled() {
        let data = NSData.dataWithLength(12)
        let URL = sut.URLForKey(name)
        sut.setData(data, key: name)
        
        sut.removeAllData()
        
        sut.performAndWait {
            XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
            XCTAssertEqual(Int(self.sut.size), 0)
        }
    }
    
    func testRemoveAllData_Empty() {
        let URL = sut.URLForKey(name)
        
        // Preconditions
        XCTAssertFalse(URL.checkResourceIsReachableAndReturnError(nil))
        
        sut.removeAllData()
    }
    
    func testRemoveAllData_ThenSetData() {
        let URL = sut.URLForKey(name)
        let data = NSData.dataWithLength(12)
        
        sut.removeAllData()

        sut.setData(data, key: name)
        sut.performAndWait {
            XCTAssertTrue(URL.checkResourceIsReachableAndReturnError(nil))
        }
    }
    
    func testPathForKey_WithShortKey() {
        let key = "test"
        let expectedURL = sut.URL.URLByAppendingPathComponent(key.hnk_escapedFilename, isDirectory: false)
        let URL = sut.URLForKey(name)

        XCTAssertEqual(sut.URLForKey(key), expectedURL)
    }
    
    func testPathForKey_WithShortKeyWithSpecialCharacters() {
        let key = "http://haneke.io"
        let expectedURL = sut.URL.URLByAppendingPathComponent(key.hnk_escapedFilename, isDirectory: false)
        
        XCTAssertEqual(sut.URLForKey(key), expectedURL)
    }
    
    func testPathForKey_WithLongKey() {
        let key = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam pretium id nibh a pulvinar. Integer id ex in tellus egestas placerat. Praesent ultricies libero ligula, et convallis ligula imperdiet eu. Sed gravida, turpis sed vulputate feugiat, metus nisl scelerisque diam, ac aliquet metus nisi rutrum ipsum. Nulla vulputate pretium dolor, a pellentesque nulla. Nunc pellentesque tortor porttitor, sollicitudin leo in, sollicitudin ligula. Cras malesuada orci at neque interdum elementum. Integer sed sagittis diam. Mauris non elit sed augue consequat feugiat. Nullam volutpat tortor eget tempus pretium. Sed pharetra sem vitae diam hendrerit, sit amet dapibus arcu interdum. Fusce egestas quam libero, ut efficitur turpis placerat eu. Sed velit sapien, aliquam sit amet ultricies a, bibendum ac nibh. Maecenas imperdiet, quam quis tincidunt sollicitudin, nunc tellus ornare ipsum, nec rhoncus nunc nisi a lacus."
        let expectedURL = sut.URL.URLByAppendingPathComponent(key.MD5Filename(), isDirectory: false)
        
        XCTAssertEqual(sut.URLForKey(key), expectedURL)
    }

}