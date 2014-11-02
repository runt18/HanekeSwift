//
//  String+Haneke.swift
//  Haneke
//
//  Created by Hermes Pique on 8/30/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import Foundation

extension String {

    private struct Filename {
        static let allowedCharacters: NSCharacterSet = {
            let charSet = NSMutableCharacterSet()
            charSet.addCharactersInString("/:")
            return charSet.invertedSet
        }()
    }

    var hnk_escapedFilename: String {
        return stringByAddingPercentEncodingWithAllowedCharacters(Filename.allowedCharacters) ?? self
    }
    
    func MD5String() -> String {
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            let MD5Calculator = MD5(data)
            let MD5Data = MD5Calculator.calculate()
            let resultBytes = UnsafeMutablePointer<CUnsignedChar>(MD5Data.bytes)
            let resultEnumerator = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: MD5Data.length)
            let MD5String = NSMutableString()
            for c in resultEnumerator {
                MD5String.appendFormat("%02x", c)
            }
            return MD5String
        } else {
            return self
        }
    }
    
    func MD5Filename() -> String {
        let MD5String = self.MD5String()
        let pathExtension = self.pathExtension
        if countElements(pathExtension) > 0 {
            return MD5String.stringByAppendingPathExtension(pathExtension) ?? MD5String
        } else {
            return MD5String
        }
    }

}