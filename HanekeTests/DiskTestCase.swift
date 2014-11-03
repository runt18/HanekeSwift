//
//  DiskTestCase.swift
//  Haneke
//
//  Created by Hermes Pique on 8/26/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import XCTest

class DiskTestCase : XCTestCase {

    let fileManager = NSFileManager()

    lazy var directoryURL: NSURL = {
        let directoryURL = self.fileManager.URLForDirectory(.AutosavedInformationDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: nil)
        return directoryURL!.URLByAppendingPathComponent(self.name, isDirectory: true)
    }()

    override func setUp() {
        super.setUp()

        fileManager.createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil, error: nil)
    }
    
    override func tearDown() {
        fileManager.removeItemAtURL(directoryURL, error: nil)

        super.tearDown()
    }
    
    // Mark: Data writing

    private var dataIndex = 0

    func uniqueURL(inDirectory directory: NSURL) -> NSURL {
        let URL = directory.URLByAppendingPathComponent("\(dataIndex)", isDirectory: false)
        dataIndex++
        return URL
    }

    func uniqueURL() -> NSURL {
        return uniqueURL(inDirectory: directoryURL)
    }

    func writeData(data: NSData, toDirectory directory: NSURL) -> NSURL {
        let URL = uniqueURL(inDirectory: directory)
        data.writeToURL(URL, atomically: true)
        return URL
    }
    
    func writeData(data: NSData) -> NSURL {
        return writeData(data, toDirectory: directoryURL)
    }

    func writeDataWithLength(length : Int, inDirectory : NSURL) -> NSURL {
        let data = NSData.dataWithLength(length)
        return writeData(data, toDirectory: inDirectory)
    }
    
    func writeDataWithLength(length : Int) -> NSURL {
        return writeDataWithLength(length, inDirectory: directoryURL)
    }

}
