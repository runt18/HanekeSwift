//
//  String+Haneke.swift
//  Haneke
//
//  Created by Hermes Pique on 8/30/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import Foundation

public extension String {
    
    private static let hex: [UnicodeScalar] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
    
    private var percentEncoded: String {
        var string = ""
        var sink = SinkOf<UInt8> {
            let low = Int($0 >> 4)
            let high = Int($0 & 0x0F)
            string += "%"
            string.append(self.dynamicType.hex[low])
            string.append(self.dynamicType.hex[high])
        }
        
        for scalar in unicodeScalars {
            UTF8.encode(scalar, output: &sink)
        }
        
        return string
    }
    
    private func withPercentEscapes(charactersInString string: String) -> String {
        var ret = self
        let set = NSCharacterSet(charactersInString: string)
        var range: Range<String.Index>? = nil
        while let foundRange = ret.rangeOfCharacterFromSet(set, options: .BackwardsSearch, range: range) {
            ret.replaceRange(foundRange, with: self[foundRange].percentEncoded)
            range = ret.startIndex...foundRange.startIndex
        }
        return ret
    }
    
    private func truncated(UTF16Length max: Int, originalLength: Int) -> String {
        let scalars = unicodeScalars
        
        var count = originalLength
        var end = scalars.endIndex
        while count > max {
            end = end.predecessor()
            count -= UTF16.width(scalars[end])
        }
        let retScalars = scalars[scalars.startIndex..<end]
        return String(retScalars)
    }
    
    private func trimmed(_ string: String? = nil, fromEnd: Bool = false) -> String {
        let characterSet = string.map { NSCharacterSet(charactersInString: $0) } ?? NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let backwards: NSStringCompareOptions = fromEnd ? .BackwardsSearch : nil
        if let range = rangeOfCharacterFromSet(characterSet, options: .AnchoredSearch | backwards) {
            return self[self.startIndex..<range.startIndex]
        }
        return self
    }
    
    public var hnk_escapedFilename: String {
        return withPercentEscapes(charactersInString: "/:")
    }
    
    public var hnk_filename: String! {
        let escaped = hnk_escapedFilename
        
        let max = Int(NAME_MAX)
        var count = escaped.utf16Count
        if count <= max {
            return escaped
        }
        
        let ext = escaped.pathExtension
        let filename = escaped.stringByDeletingPathExtension.truncated(UTF16Length: max, originalLength: count).trimmed(fromEnd: true)
        return filename.stringByAppendingPathExtension(ext)
    }

}