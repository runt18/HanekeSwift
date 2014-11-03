//
//  DiskCache.swift
//  Haneke
//
//  Created by Hermes Pique on 8/10/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import Foundation

public class DiskCache {
    
    class func baseURL(#fileManager: NSFileManager) -> NSURL! {
        if let cachesURL = fileManager.URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: nil) {
            return cachesURL.URLByAppendingPathComponent(Haneke.Domain, isDirectory: true)
        }
        return nil
    }

    class func cacheURL(#fileManager: NSFileManager, name: String = "") -> NSURL! {
        let base = baseURL(fileManager: fileManager)
        let cacheURL = name.isEmpty ? base : base.URLByAppendingPathComponent(name, isDirectory: true)
        var error : NSError?
        let success = fileManager.createDirectoryAtURL(cacheURL, withIntermediateDirectories: true, attributes: nil, error: &error)
        if (!success) {
            NSLog("Failed to create directory \(cacheURL) with error \(error!)")
        }
        return cacheURL
    }

    private let fileManager: NSFileManager
    public let URL: NSURL
    private(set) public var size : UInt64 = 0
    public var capacity : UInt64 = 0 {
        didSet {
            self.perform(controlCapacity)
        }
    }

    private lazy var cacheQueue : dispatch_queue_t = {
        let queueName = Haneke.Domain + "." + self.URL.lastPathComponent
        let queueAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0)
        let queue = dispatch_queue_create(queueName, queueAttr)
        return queue
    }()
    
    public convenience init(path: String, capacity: UInt64 = UINT64_MAX) {
        let cacheURL = NSURL.fileURLWithPath(path, isDirectory: true)!
        self.init(URL: cacheURL, capacity: capacity)
    }

    public convenience init(name: String, capacity: UInt64 = UINT64_MAX) {
        let fm = NSFileManager()
        let URL = DiskCache.cacheURL(fileManager: fm, name: name)
        self.init(URL: URL, capacity: capacity, fileManager: fm)
    }

    public init(URL: NSURL, capacity: UInt64 = UINT64_MAX, fileManager: NSFileManager = NSFileManager()) {
        self.URL = URL
        self.fileManager = fileManager
        self.perform(calculateSize)
        if capacity > 0 {
            self.capacity = capacity
        } else {
            self.perform(controlCapacity)
        }
    }
    
    public func setData(getData : @autoclosure () -> NSData?, key : String) {
        dispatch_async(cacheQueue) {
            self.setDataSync(getData, key: key)
        }
    }
    
    public func fetchData(key : String, failure fail : ((NSError?) -> ())? = nil, success succeed : (NSData) -> ()) {
        dispatch_async(cacheQueue) {
            let itemURL = self.URLForKey(key)
            var error: NSError? = nil
            if let data = NSData(contentsOfURL: itemURL, options: .DataReadingMappedIfSafe, error: &error) {
                dispatch_async(dispatch_get_main_queue()) {
                   succeed(data)
                }
            } else if let block = fail {
                dispatch_async(dispatch_get_main_queue()) {
                    block(error)
                }
            }
        }
    }

    public func removeData(key : String) {
        dispatch_async(cacheQueue) {
            var error: NSError?
            let itemURL = self.URLForKey(key)
            let subtractSize = itemURL.mapResourceValue(forKey: NSURLFileSizeKey, success: { (sizeV: NSNumber) in
                return sizeV.unsignedLongLongValue
            }, failure: UInt64(0))

            if self.fileManager.removeItemAtURL(itemURL, error: &error) {
                self.size -= subtractSize
            } else {
                Log.error("Failed to remove key \(key) with error \(error!)")
            }
        }
    }
    
    public func removeAllData() {
        dispatch_async(cacheQueue) {
            var error: NSError?
            let fm = self.fileManager
            for item in fm.contents(directoryAtURL: self.URL, includingProperties: nil) {
                if !fm.removeItemAtURL(item, error: &error) {
                    Log.error("Failed to remove item \(item) with error \(error!)")
                }
            }
            self.calculateSize()
        }
    }

    public func updateAccessDate(getData : @autoclosure () -> NSData?, key : String) {
        dispatch_async(cacheQueue, {
            let itemURL = self.URLForKey(key)
            if (!itemURL.checkResourceIsReachableAndReturnError(nil)){
                self.setDataSync(getData, key: key)
            }
        })
    }

    func URLForKey(key: String) -> NSURL {
        let filename = key.utf16Count > Int(NAME_MAX) ? key.MD5Filename() : key.hnk_escapedFilename
        let itemURL = URL.URLByAppendingPathComponent(filename, isDirectory: false)
        return itemURL
    }
    
    // MARK: Private
    
    private func calculateSize() {
        size = reduce(fileManager.contents(directoryAtURL: URL, includingProperties: [ NSURLFileSizeKey ]), 0) {
            $0 + $1.mapResourceValue(forKey: NSURLFileSizeKey, success: { (sizeV: NSNumber) in
                return sizeV.unsignedLongLongValue
            }, failure: UInt64(0))
        }
    }
    
    private func controlCapacity() {
        if size <= capacity { return }
        
        for itemURL in fileManager.contents(directoryAtURL: URL, sortedByResourceValue: NSURLContentAccessDateKey, isOrderedBefore: NSFileManager.Utilities.DatesOrderedBefore) {
            removeItem(atURL: itemURL)
            if size <= capacity { break }
        }
    }
    
    private func setDataSync(getData: () -> NSData?, key : String) {
        let itemURL = URLForKey(key)
        if let data = getData() {
            let previousSize = itemURL.mapResourceValue(forKey: NSURLFileSizeKey, success: { (sizeV: NSNumber) in
                return sizeV.unsignedLongLongValue
            }, failure: UInt64(0))

            var error: NSError? = nil
            if data.writeToURL(itemURL, options: .DataWritingAtomic, error: &error) {
                size += UInt64(data.length) - previousSize
                controlCapacity()
            } else {
                Log.error("Failed to write key \(key) with error \(error!)")
            }
        } else {
            Log.error("Failed to get data for key \(key)")
        }
    }
    
    private func removeItem(atURL itemURL: NSURL) -> Bool {
        let subtractSize: Int = itemURL.mapResourceValue(forKey: NSURLFileSizeKey, success: { (size: NSNumber) -> Int in
            return size.unsignedIntegerValue
        }, failure: 0)

        var error : NSError?
        if fileManager.removeItemAtURL(itemURL, error: &error) {
            size -= subtractSize
            return true
        }
        Log.error("Failed to remove file with error \(error)")
        return false
    }

    // MARK - Block performing

    public func performAndWait<T>(block: () -> T?) -> T? {
        var ret: T?
        dispatch_sync(cacheQueue) {
            ret = block()
        }
        return ret
    }

    public func performAndWait(block: () -> ()) {
        dispatch_sync(cacheQueue, block)
    }

    public func perform(block: () -> ()) {
        dispatch_async(cacheQueue, block)
    }


}
