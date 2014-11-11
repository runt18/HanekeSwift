//
//  String+Haneke.swift
//  Haneke
//
//  Created by Hermes Pique on 8/30/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import Foundation

extension String {
    
    func trimmed(_ string: String? = nil, fromEnd: Bool = false) -> String {
        let characterSet = string.map { NSCharacterSet(charactersInString: $0) } ?? NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let backwards: NSStringCompareOptions = fromEnd ? .BackwardsSearch : nil
        if let range = rangeOfCharacterFromSet(characterSet, options: .AnchoredSearch | backwards) {
            return self[range]
        }
        return self
    }
    
}

extension String.UnicodeScalarView {
    
    func truncate(UTF16Length maxLength: Int, originalLength: Int) -> String {
        var utf16 = originalLength
        var endIndex = self.endIndex
        while utf16 > maxLength {
            endIndex = endIndex.predecessor()
            utf16 -= UTF16.width(self[endIndex])
        }
        let retScalars = self[startIndex..<endIndex]
        return String(retScalars).trimmed(fromEnd: true)
    }
    
}

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
    
    var hnk_truncatedFilename: String {
        let max = Int(NAME_MAX)
        var count = utf16Count
        if count <= max {
            return self
        }
        
        let ext = pathExtension
        let name = stringByDeletingPathExtension
        let newName = name.unicodeScalars.truncate(UTF16Length: max, originalLength: count)
        return newName.stringByAppendingPathExtension(ext)!
    }
    
    var hnk_filename: String {
        return hnk_escapedFilename.hnk_truncatedFilename
    }

}