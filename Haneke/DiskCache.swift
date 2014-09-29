//
//  DiskCache.swift
//  Haneke
//
//  Created by Hermes Pique on 8/10/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import Foundation

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
}

extension NSDate: Equatable, Comparable {}

public class DiskCache {
    public class func baseURL(fileManager: NSFileManager) -> NSURL! {
        if let cachesURL = fileManager.URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: nil) {
            return cachesURL.URLByAppendingPathComponent(Haneke.Domain, isDirectory: true)
        }
        return nil
    }
    
    var baseURL : NSURL! {
        return DiskCache.baseURL(fileManager)
    }
    
    private lazy var fileManager = NSFileManager()
    
    public let name : String

    public private(set) var size : Int = 0

    public var capacity : Int = 0 {
        didSet {
            dispatch_async(self.cacheQueue, {
                self.controlCapacity()
            })
        }
    }
    
    public lazy var cacheURL: NSURL! = {
        let cacheURL = self.name.isEmpty ? self.baseURL : self.baseURL.URLByAppendingPathComponent(self.name, isDirectory: true)
        var error : NSError?
        let success = self.fileManager.createDirectoryAtURL(cacheURL, withIntermediateDirectories: true, attributes: nil, error: &error)
        if (!success) {
            println("Failed to create directory \(cacheURL) with error \(error!)")
        }
        return cacheURL
    }()

    public lazy var cacheQueue : dispatch_queue_t = {
        let queueName = Haneke.Domain + "." + self.name
        let cacheQueue = dispatch_queue_create(queueName, nil)
        return cacheQueue
    }()
    
    public func performBlockAndWait<T>(block: () -> T?) -> T? {
        var ret: T?
        dispatch_sync(cacheQueue) {
            ret = block()
        }
        return ret
    }
    
    public func performBlockAndWait(block: () -> ()) {
        dispatch_sync(cacheQueue, block)
    }
    
    public init(_ name : String, capacity : Int) {
        self.name = name
        self.capacity = capacity
        dispatch_async(self.cacheQueue, {
            self.calculateSize()
            self.controlCapacity()
        })
    }
    
    public func setData(getData : @autoclosure () -> NSData?, key : String) {
        dispatch_async(cacheQueue, {
            self.setDataSync(getData, key: key)
        })
    }
    
    public func fetchData(key : String, success doSuccess : (NSData) -> (), failure doFailure : ((NSError?) -> ())? = nil) {
        let URL = URLForKey(key)
        dispatch_async(cacheQueue, {
            var error: NSError? = nil
            if let data = NSData.dataWithContentsOfURL(URL, options: .DataReadingMappedIfSafe, error: &error) {
                dispatch_async(dispatch_get_main_queue(), {
                    doSuccess(data)
                })
                self.updateDiskAccessDateAtURL(URL)
            } else if let block = doFailure {
                dispatch_async(dispatch_get_main_queue(), {
                    block(error)
                })
            }
        })
    }

    public func removeData(key : String) {
        let URL = URLForKey(key)
        dispatch_async(cacheQueue) {
            let subtractSize = URL.mapResourceValueForKey(NSURLFileSizeKey, success: { (size: NSNumber) in
                return size.unsignedIntegerValue
            }, failure: 0)
            
            var error: NSError?
            if self.fileManager.removeItemAtURL(URL, error: &error) {
                self.size -= subtractSize
            } else {
                NSLog("Failed to remove key \(key) with error \(error!)")
            }
        }
    }
    
    public func removeAllData() {
        dispatch_async(cacheQueue, {
            var error: NSError? = nil
            if self.fileManager.removeItemAtURL(self.cacheURL, error: &error) {
                self.size = 0
            } else {
                println("Failed to remove all data with error \(error!)")
            }
        })
    }

    public func updateAccessDate(getData : @autoclosure () -> NSData?, key : String) {
        let URL = URLForKey(key)
        dispatch_async(cacheQueue, {
            if (!self.updateDiskAccessDateAtURL(URL) && !URL.checkResourceIsReachableAndReturnError(nil)){
                let data = getData()
                self.setDataSync(data, key: key)
            }
        })
    }
    
    public func URLForKey(key : String) -> NSURL {
        let filename = key.escapedFilename
        return cacheURL.URLByAppendingPathComponent(filename, isDirectory: false)
    }
    
    // MARK: Private
    
    private func calculateSize() {
        let contents = fileManager.contentsOfDirectoryAtURL(cacheURL, includingPropertiesForKeys: [NSURLFileSizeKey], options: nil, error: nil) as [NSURL]?
        if let contents = fileManager.contentsOfDirectoryAtURL(cacheURL, includingPropertiesForKeys: [NSURLFileSizeKey], options: nil, error: nil) as [NSURL]? {
            size = contents.reduce(0) { (last, URL) in
                return URL.mapResourceValueForKey(NSURLFileSizeKey, success: { (size: NSNumber) in
                    return last + size.unsignedIntegerValue
                }, failure: last)
            }
        } else {
            size = 0
        }
    }
    
    private func controlCapacity() {
        if self.size <= self.capacity { return }
        
        for URL in fileManager.enumerateContentsOfDirectoryAtURL(cacheURL, byProperty: NSURLContentModificationDateKey, isOrderedBefore: { (a: NSDate, b: NSDate) in
            return a < b
        }) {
            removeFileAtURL(URL)
            if self.size <= self.capacity { break }
        }
    }
    
    private func setDataSync(getData : @autoclosure () -> NSData?, key : String) {
        let URL = URLForKey(key)
        var error: NSError?
        if let data = getData() {
            let subtractSize = URL.mapResourceValueForKey(NSURLFileSizeKey, success: { (size: NSNumber) in
                return size.unsignedIntegerValue
            }, failure: 0)
            
            if !data.writeToURL(URL, options: .AtomicWrite, error: &error) {
                println("Failed to write key \(key) with error \(error!)")
            }
            
            size = size - subtractSize + data.length
            
            controlCapacity()
        }
    }
    
    private func updateDiskAccessDateAtURL(URL: NSURL) -> Bool {
        var error : NSError?
        let success = URL.setResourceValue(NSDate(), forKey: NSURLContentModificationDateKey, error: &error)
        if !success {
            NSLog("Failed to update access date with error \(error!)")
        }
        return success
    }
    
    private func removeFileAtURL(URL: NSURL) -> Bool {
        let subtractSize = URL.mapResourceValueForKey(NSURLFileSizeKey, success: { (size: NSNumber) in
            return size.unsignedIntegerValue
        }, failure: 0)
        
        let success = fileManager.removeItemAtURL(URL, error: nil)
        size -= subtractSize
        return success
    }
}
