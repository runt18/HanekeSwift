//
//  DiskCacheTests.swift
//  Haneke
//
//  Created by Hermes Pique on 8/10/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit
import XCTest

class DiskCacheTests: DiskTestCase {

    var sut : DiskCache!
    
    override func setUp() {
        super.setUp()
        sut = DiskCache(path: directoryPathOld)
    }
    
    override func tearDown() {
        sut.removeAllData()
        super.tearDown()
    }
    
    func testBasePath() {
        let cachesPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        let basePath = cachesPath.stringByAppendingPathComponent(Haneke.Domain)
        XCTAssertEqual(DiskCache.basePath(), basePath)
    }
    
    func testInit() {
        let path = directoryPathOld
        let sut = DiskCache(path: path)
        
        XCTAssertEqual(sut.path, path)
        XCTAssertEqual(Int(sut.size), 0)
    }
    
    func testInitWithOneFile() {
        let name = self.name
        let path = directoryPathOld
        let expectedSize = 8
        writeDataWithLengthOld(expectedSize, inDirectory: path)
        
        let sut = DiskCache(path: path)
        
        sut.performAndWait {
            XCTAssertEqual(sut.size, UInt64(expectedSize))
        }
    }
    
    func testInitWithTwoFiles() {
        let name = self.name
        let directory = directoryPathOld
        let lengths = [4, 7]
        writeDataWithLengthOld(lengths[0], inDirectory: directory)
        writeDataWithLengthOld(lengths[1], inDirectory: directory)
        
        let sut = DiskCache(path: directory)
        
        sut.performAndWait {
            XCTAssertEqual(sut.size, UInt64(lengths.reduce(0, +)))
        }
    }
    
    func testInitCapacityZeroOneExistingFile() {
        let name = self.name
        let directory = directoryPathOld
        let path = writeDataWithLengthOld(1, inDirectory: directory)
        
        let sut = DiskCache(path: directory, capacity : 0)
        
        sut.performAndWait {
            XCTAssertEqual(Int(sut.size), 0)
            XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(path))
        }
    }
    
    func testInitCapacityZeroTwoExistingFiles() {
        let name = self.name
        let directory = directoryPathOld
        let path1 = writeDataWithLengthOld(1, inDirectory: directory)
        let path2 = writeDataWithLengthOld(2, inDirectory: directory)
        
        let sut = DiskCache(path: directory, capacity : 0)
        
        sut.performAndWait {
            XCTAssertEqual(Int(sut.size), 0)
            XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(path1))
            XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(path2))
        }
    }
    
    func testInitLeastRecentlyUsedExistingFileDeleted() {
        let name = self.name
        let directory = directoryPathOld
        let path1 = writeDataWithLengthOld(1, inDirectory: directory)
        let path2 = writeDataWithLengthOld(1, inDirectory: directory)
        NSFileManager.defaultManager().setAttributes([NSFileModificationDate : NSDate.distantPast()], ofItemAtPath: path2, error: nil)
        
        let sut = DiskCache(path: directory, capacity : 1)
        
        sut.performAndWait {
            XCTAssertEqual(Int(sut.size), 1)
            XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(path1))
            XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(path2))
        }
    }
    
    func testSetCapacity() {
        sut.setData(NSData.dataWithLength(1), key: self.name)
        
        sut.capacity = 0
        
        sut.performAndWait {
            XCTAssertEqual(Int(self.sut.size), 0)
        }
    }
    
    func testSetData() {
        let data = UIImagePNGRepresentation(UIImage.imageWithColor(UIColor.redColor()))
        let key = self.name
        let path = sut.pathForKey(key)
        
        sut.setData(data, key: key)
        
        sut.performAndWait {
            let fileManager = NSFileManager.defaultManager()
            XCTAssertTrue(fileManager.fileExistsAtPath(path))
            let resultData = NSData(contentsOfFile:path)!
            XCTAssertEqual(resultData, data)
            XCTAssertEqual(self.sut.size, UInt64(data.length))
        }
    }
    
    func testSetData_WithKeyIncludingSpecialCharacters() {
        let sut = self.sut!
        let data = UIImagePNGRepresentation(UIImage.imageWithColor(UIColor.redColor()))
        let key = "http://haneke.io"
        let path = sut.pathForKey(key)
        
        sut.setData(data, key: key)
        
        sut.performAndWait {
            let fileManager = NSFileManager.defaultManager()
            XCTAssertTrue(fileManager.fileExistsAtPath(path))
            let resultData = NSData(contentsOfFile:path)!
            XCTAssertEqual(resultData, data)
            XCTAssertEqual(sut.size, UInt64(data.length))
        }
    }
    
    func testSetData_WithLongKey() {
        let sut = self.sut!
        let data = NSData.dataWithLength(10)
        let key = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam pretium id nibh a pulvinar. Integer id ex in tellus egestas placerat. Praesent ultricies libero ligula, et convallis ligula imperdiet eu. Sed gravida, turpis sed vulputate feugiat, metus nisl scelerisque diam, ac aliquet metus nisi rutrum ipsum. Nulla vulputate pretium dolor, a pellentesque nulla. Nunc pellentesque tortor porttitor, sollicitudin leo in, sollicitudin ligula. Cras malesuada orci at neque interdum elementum. Integer sed sagittis diam. Mauris non elit sed augue consequat feugiat. Nullam volutpat tortor eget tempus pretium. Sed pharetra sem vitae diam hendrerit, sit amet dapibus arcu interdum. Fusce egestas quam libero, ut efficitur turpis placerat eu. Sed velit sapien, aliquam sit amet ultricies a, bibendum ac nibh. Maecenas imperdiet, quam quis tincidunt sollicitudin, nunc tellus ornare ipsum, nec rhoncus nunc nisi a lacus."
        let path = sut.pathForKey(key)
        
        sut.setData(data, key: key)
        
        sut.performAndWait {
            let fileManager = NSFileManager.defaultManager()
            XCTAssertTrue(fileManager.fileExistsAtPath(path))
            let resultData = NSData(contentsOfFile:path)!
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
        let key = self.name
        let path = sut.pathForKey(key)
        sut.setData(originalData, key: key)
        
        sut.setData(data, key: key)
        
        sut.performAndWait {
            let fileManager = NSFileManager.defaultManager()
            XCTAssertTrue(fileManager.fileExistsAtPath(path))
            let resultData = NSData(contentsOfFile:path)!
            XCTAssertEqual(resultData, data)
            XCTAssertEqual(self.sut.size, UInt64(data.length))
        }
    }
    
    func testSetDataNil() {
        let key = self.name
        let path = sut.pathForKey(key)
        
        sut.setData({ return nil }(), key: key)
        
        sut.performAndWait {
            let fileManager = NSFileManager.defaultManager()
            XCTAssertFalse(fileManager.fileExistsAtPath(path))
            XCTAssertEqual(Int(self.sut.size), 0)
        }
    }
    
    func testSetDataControlCapacity() {
        let sut = DiskCache(path: directoryPathOld, capacity:0)
        let key = self.name
        let path = sut.pathForKey(key)
        
        sut.setData(NSData.dataWithLength(1), key: key)
        
        sut.performAndWait {
            let fileManager = NSFileManager.defaultManager()
            XCTAssertFalse(fileManager.fileExistsAtPath(path))
            XCTAssertEqual(Int(sut.size), 0)
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
        let key = self.name
        sut.setData(data, key : key)
        let path = sut.pathForKey(key)
        let fileManager = NSFileManager.defaultManager()
        sut.performAndWait {
            _ = fileManager.setAttributes([NSFileModificationDate : NSDate.distantPast()], ofItemAtPath: path, error: nil)
        }
        let expectation = self.expectationWithDescription(self.name)
        
        // Preconditions
        sut.performAndWait {
            let attributes = fileManager.attributesOfItemAtPath(path, error: nil)!
            let accessDate = attributes[NSFileModificationDate] as NSDate
            XCTAssertEqual(accessDate, NSDate.distantPast() as NSDate)
        }
        
        sut.fetchData(key, success: {
            expectation.fulfill()
            XCTAssertEqual($0, data)
        })
        
        sut.performAndWait {
            self.waitForExpectationsWithTimeout(0, nil)
            
            let attributes = fileManager.attributesOfItemAtPath(path, error: nil)!
            let accessDate = attributes[NSFileModificationDate] as NSDate
            let now = NSDate()
            let interval = accessDate.timeIntervalSinceDate(now)
            XCTAssertEqualWithAccuracy(interval, 0, 1)
        }
    }
    
    func testUpdateAccessDateFileInDisk() {
        let data = NSData.dataWithLength(10)
        let key = self.name
        sut.setData(data, key : key)
        let path = sut.pathForKey(key)
        let fileManager = NSFileManager.defaultManager()
        sut.performAndWait {
            let _ = fileManager.setAttributes([NSFileModificationDate : NSDate.distantPast()], ofItemAtPath: path, error: nil)
        }
        
        // Preconditions
        sut.performAndWait {
            let attributes = fileManager.attributesOfItemAtPath(path, error: nil)!
            let accessDate = attributes[NSFileModificationDate] as NSDate
            XCTAssertEqual(accessDate, NSDate.distantPast() as NSDate)
        }
        
        sut.updateAccessDate(data, key: key)
        
        sut.performAndWait {
            let attributes = fileManager.attributesOfItemAtPath(path, error: nil)!
            let accessDate = attributes[NSFileModificationDate] as NSDate
            let now = NSDate()
            let interval = accessDate.timeIntervalSinceDate(now)
            XCTAssertEqualWithAccuracy(interval, 0, 1)
        }
    }
    
    func testUpdateAccessDateFileNotInDisk() {
        let image = UIImage.imageWithColor(UIColor.redColor())
        let key = self.name
        let path = sut.pathForKey(key)
        let fileManager = NSFileManager.defaultManager()
        
        // Preconditions
        sut.performAndWait {
            XCTAssertFalse(fileManager.fileExistsAtPath(path))
        }
        
        sut.updateAccessDate(image.hnk_data(), key: key)
        
        sut.performAndWait {
            XCTAssertTrue(fileManager.fileExistsAtPath(path))
        }
    }
    
    func testRemoveDataTwoKeys() {
        let keys = ["1", "2"]
        let datas = [NSData.dataWithLength(5), NSData.dataWithLength(7)]
        sut.setData(datas[0], key: keys[0])
        sut.setData(datas[1], key: keys[1])

        sut.removeData(keys[1])
        
        sut.performAndWait {
            let fileManager = NSFileManager.defaultManager()
            let path = self.sut.pathForKey(keys[1])
            XCTAssertFalse(fileManager.fileExistsAtPath(path))
            XCTAssertEqual(self.sut.size, UInt64(datas[0].length))
        }
    }
    
    func testRemoveDataExisting() {
        let key = self.name
        let data = UIImagePNGRepresentation(UIImage.imageWithColor(UIColor.redColor()))
        let path = sut.pathForKey(key)
        sut.setData(data, key: key)
        
        sut.removeData(key)
        
        sut.performAndWait {
            let fileManager = NSFileManager.defaultManager()
            XCTAssertFalse(fileManager.fileExistsAtPath(path))
            XCTAssertEqual(Int(self.sut.size), 0)
        }
    }
    
    func testRemoveDataInexisting() {
        let key = self.name
        let path = sut.pathForKey(key)
        let fileManager = NSFileManager.defaultManager()
        
        // Preconditions
        XCTAssertFalse(fileManager.fileExistsAtPath(path))
        
        sut.removeData(self.name)
    }
    
    func testRemoveAllData_Filled() {
        let key = self.name
        let data = NSData.dataWithLength(12)
        let path = sut.pathForKey(key)
        sut.setData(data, key: key)
        
        sut.removeAllData()
        
        sut.performAndWait {
            let fileManager = NSFileManager.defaultManager()
            XCTAssertFalse(fileManager.fileExistsAtPath(path))
            XCTAssertEqual(Int(self.sut.size), 0)
        }
    }
    
    func testRemoveAllData_Empty() {
        let key = self.name
        let path = sut.pathForKey(key)
        let fileManager = NSFileManager.defaultManager()
        
        // Preconditions
        XCTAssertFalse(fileManager.fileExistsAtPath(path))
        
        sut.removeAllData()
    }
    
    func testRemoveAllData_ThenSetData() {
        let key = self.name
        let path = sut.pathForKey(key)
        let data = NSData.dataWithLength(12)
        let fileManager = NSFileManager.defaultManager()
        
        sut.removeAllData()

        sut.setData(data, key: key)
        sut.performAndWait {
            let fileManager = NSFileManager.defaultManager()
            XCTAssertTrue(fileManager.fileExistsAtPath(path))
        }
    }
    
    func testPathForKey_WithShortKey() {
        let key = "test"
        let expectedPath = sut.path.stringByAppendingPathComponent(key.hnk_escapedFilename)

        XCTAssertEqual(sut.pathForKey(key), expectedPath)
    }
    
    func testPathForKey_WithShortKeyWithSpecialCharacters() {
        let key = "http://haneke.io"
        let expectedPath = sut.path.stringByAppendingPathComponent(key.hnk_escapedFilename)
        
        XCTAssertEqual(sut.pathForKey(key), expectedPath)
    }
    
    func testPathForKey_WithLongKey() {
        let key = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam pretium id nibh a pulvinar. Integer id ex in tellus egestas placerat. Praesent ultricies libero ligula, et convallis ligula imperdiet eu. Sed gravida, turpis sed vulputate feugiat, metus nisl scelerisque diam, ac aliquet metus nisi rutrum ipsum. Nulla vulputate pretium dolor, a pellentesque nulla. Nunc pellentesque tortor porttitor, sollicitudin leo in, sollicitudin ligula. Cras malesuada orci at neque interdum elementum. Integer sed sagittis diam. Mauris non elit sed augue consequat feugiat. Nullam volutpat tortor eget tempus pretium. Sed pharetra sem vitae diam hendrerit, sit amet dapibus arcu interdum. Fusce egestas quam libero, ut efficitur turpis placerat eu. Sed velit sapien, aliquam sit amet ultricies a, bibendum ac nibh. Maecenas imperdiet, quam quis tincidunt sollicitudin, nunc tellus ornare ipsum, nec rhoncus nunc nisi a lacus."
        let expectedPath = sut.path.stringByAppendingPathComponent(key.MD5Filename())
        
        XCTAssertEqual(sut.pathForKey(key), expectedPath)
    }

}