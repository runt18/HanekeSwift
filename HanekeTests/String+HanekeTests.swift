//
//  String+HanekeTests.swift
//  Haneke
//
//  Created by Hermes Pique on 8/30/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import XCTest

class String_HanekeTests: XCTestCase {

    func testEscapedFilename() {
        XCTAssertEqual("".hnk_escapedFilename, "")
        XCTAssertEqual(":".hnk_escapedFilename, "%3A")
        XCTAssertEqual("/".hnk_escapedFilename, "%2F")
        XCTAssertEqual(" ".hnk_escapedFilename, " ")
        XCTAssertEqual("\\".hnk_escapedFilename, "\\")
        XCTAssertEqual("test".hnk_escapedFilename, "test")
        XCTAssertEqual("http://haneke.io".hnk_escapedFilename, "http%3A%2F%2Fhaneke.io")
        XCTAssertEqual("/path/to/file".hnk_escapedFilename, "%2Fpath%2Fto%2Ffile")
    }
    
    func testTruncatedFilename() {
        let key = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin a ante odio. Quisque nisi lectus, hendrerit sed lorem vitae, cursus egestas eros. Aenean at fermentum quam. Ut tristique leo ante, sed egestas ex cursus quis. Curabitur lacinia cras amet 🎩.hnk"
        let filename = key.hnk_filename
        let expectedFilename = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin a ante odio. Quisque nisi lectus, hendrerit sed lorem vitae, cursus egestas eros. Aenean at fermentum quam. Ut tristique leo ante, sed egestas ex cursus quis. Curabitur lacinia cras amet.foo"
        XCTAssertEqual(filename, expectedFilename)
    }
        
}