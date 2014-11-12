//
//  HanekeTests.swift
//  Haneke
//
//  Created by Hermes Pique on 9/9/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import XCTest
import Haneke

class HanekeTests: XCTestCase {

    enum TestError: Int, ErrorRepresentable {
        case Test = 200

        static var domain: String {
            return Haneke.Domain + ".tests"
        }
    }

    func testErrorWithCode() {
        let code = TestError.Test
        let description = self.name
        let error = errorWithCode(code, description: description)
        
        XCTAssertTrue(error == code)
        XCTAssertEqual(error.localizedDescription, description)
    }
    
    func testSharedImageCache() {
        let cache = Haneke.sharedImageCache
    }
    
    func testSharedDataCache() {
        let cache = Haneke.sharedDataCache
    }
    
    func testSharedStringCache() {
        let cache = Haneke.sharedStringCache
    }
    
    func testSharedJSONCache() {
        let cache = Haneke.sharedJSONCache
    }
    
}
