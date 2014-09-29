//
//  DiskTestCase.swift
//  Haneke
//
//  Created by Hermes Pique on 8/26/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import XCTest

class DiskTestCase : XCTestCase {
    internal lazy var fileManager: NSFileManager! = NSFileManager()
    
    override func setUp() {
        super.setUp()
        fileManager.createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil, error: nil)
    }
    
    override func tearDown() {
        fileManager.removeItemAtURL(directoryURL, error: nil)
        fileManager = nil
        super.tearDown()
    }
 
    lazy var directoryURL : NSURL! = {
        let directoryURL = self.fileManager.URLForDirectory(.AutosavedInformationDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: nil)
        return directoryURL?.URLByAppendingPathComponent(_stdlib_getTypeName(self), isDirectory: true)
    }()

    var dataIndex = 0
    
    func writeDataWithLength(length : Int, directory : NSURL) -> NSURL {
        let data = NSData.dataWithLength(length)
        let URL = directory.URLByAppendingPathComponent("\(dataIndex)", isDirectory: false)
        data.writeToURL(URL, atomically: true)
        dataIndex++
        return URL
    }
    
    func writeDataWithLength(length : Int) -> NSURL {
        return writeDataWithLength(length, directory: directoryURL)
    }
}
