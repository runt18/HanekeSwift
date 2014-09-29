//
//  String+Haneke.swift
//  Haneke
//
//  Created by Hermes Pique on 8/30/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import Foundation

extension String {
    
    struct Filename {
        static let allowedCharacters: NSCharacterSet = {
            let charSet = NSMutableCharacterSet()
            charSet.addCharactersInString("/:")
            return charSet.invertedSet
        }()
    }
    
    var escapedFilename: String {
        return stringByAddingPercentEncodingWithAllowedCharacters(Filename.allowedCharacters) ?? self
    }

}