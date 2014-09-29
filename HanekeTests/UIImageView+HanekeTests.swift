//
//  UIImageView+HanekeTests.swift
//  Haneke
//
//  Created by Hermes Pique on 9/17/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit
import XCTest

class UIImageView_HanekeTests: XCTestCase {
    
    enum ImageViewTestError: Int, ErrorRepresentable {
        case Test = 0
        
        static var domain: String {
            return "io.haneke.tests.imageView"
        }
    }

    var sut : UIImageView!
    
    /*override func setUp() {
        super.setUp()
        sut = UIImageView(frame: CGRectMake(0, 0, 10, 10))
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        
        let format = sut.hnk_format
        let cache = Haneke.sharedImageCache
        cache.removeAllValues()
        super.tearDown()
    }
    
    func testScaleMode_ScaleToFill() {
        sut.contentMode = .ScaleToFill
        XCTAssertEqual(sut.hnk_scaleMode, ScaleMode.Fill)
    }
    
    func testScaleMode_ScaleAspectFit() {
        sut.contentMode = .ScaleAspectFit
        XCTAssertEqual(sut.hnk_scaleMode, ScaleMode.AspectFit)
    }
    
    func testScaleMode_ScaleAspectFill() {
        sut.contentMode = .ScaleAspectFill
        XCTAssertEqual(sut.hnk_scaleMode, ScaleMode.AspectFill)
    }
    
    func testScaleMode_Redraw() {
        sut.contentMode = .Redraw
        XCTAssertEqual(sut.hnk_scaleMode, ScaleMode.None)
    }
    
    func testScaleMode_Center() {
        sut.contentMode = .Center
        XCTAssertEqual(sut.hnk_scaleMode, ScaleMode.None)
    }
    
    func testScaleMode_Top() {
        sut.contentMode = .Top
        XCTAssertEqual(sut.hnk_scaleMode, ScaleMode.None)
    }
    
    func testScaleMode_Bottom() {
        sut.contentMode = .Bottom
        XCTAssertEqual(sut.hnk_scaleMode, ScaleMode.None)
    }
    
    func testScaleMode_Left() {
        sut.contentMode = .Left
        XCTAssertEqual(sut.hnk_scaleMode, ScaleMode.None)
    }
    
    func testScaleMode_Right() {
        sut.contentMode = .Right
        XCTAssertEqual(sut.hnk_scaleMode, ScaleMode.None)
    }
    
    func testScaleMode_TopLeft() {
        sut.contentMode = .TopLeft
        XCTAssertEqual(sut.hnk_scaleMode, ScaleMode.None)
    }
    
    func testScaleMode_TopRight() {
        sut.contentMode = .TopRight
        XCTAssertEqual(sut.hnk_scaleMode, ScaleMode.None)
    }
    
    func testScaleMode_BottomLeft() {
        sut.contentMode = .BottomLeft
        XCTAssertEqual(sut.hnk_scaleMode, ScaleMode.None)
    }
    
    func testScaleMode_BottomRight() {
        sut.contentMode = .BottomRight
        XCTAssertEqual(sut.hnk_scaleMode, ScaleMode.None)
    }
    
    func testFormatWithSize() {
        let size = CGSizeMake(10, 20)
        let scaleMode = ScaleMode.Fill
        let cache = Haneke.sharedImageCache
        let image = UIImage.imageWithColor(UIColor.redColor())
        let resizer = ImageResizer(size: size, scaleMode: scaleMode, allowUpscaling: true, compressionQuality: Haneke.UIKit.DefaultFormat.CompressionQuality)
        
        let format = UIImageView.hnk_formatWithSize(size, scaleMode: scaleMode)
        
        XCTAssertEqual(format.diskCapacity, Haneke.UIKit.DefaultFormat.DiskCapacity)
        XCTAssertTrue(cache.formats[format.name] != nil) // Can't use XCTAssertNotNil because it expects AnyObject
        let result = format.apply(image)
        let expected = resizer.resizeImage(image)
        XCTAssertTrue(result.isEqualPixelByPixel(expected))
    }
    
    func testFormatWithSize_Twice() {
        let size = CGSizeMake(10, 20)
        let scaleMode = ScaleMode.Fill
        let cache = Haneke.sharedImageCache
        let format1 = UIImageView.hnk_formatWithSize(size, scaleMode: scaleMode)
        let image = UIImage.imageWithColor(UIColor.greenColor())
        cache.setValue(image, self.name, formatName: format1.name)
        
        let format2 = UIImageView.hnk_formatWithSize(size, scaleMode: scaleMode)
        
        let (_,memoryCache,_) = cache.formats[format2.name]!
        let wrapper = memoryCache.objectForKey(self.name)! as ObjectWrapper
        let resultImage = wrapper.value as UIImage
        XCTAssertEqual(resultImage, image)
    }
    
    func testFormat_Default() {
        let cache = Haneke.sharedImageCache
        let resizer = ImageResizer(size: sut.bounds.size, scaleMode: sut.hnk_scaleMode, allowUpscaling: true, compressionQuality: Haneke.UIKit.DefaultFormat.CompressionQuality)
        let image = UIImage.imageWithColor(UIColor.greenColor())
        
        let format = sut.hnk_format
        
        XCTAssertEqual(format.diskCapacity, Haneke.UIKit.DefaultFormat.DiskCapacity)
        XCTAssertTrue(cache.formats[format.name] != nil) // Can't use XCTAssertNotNil because it expects AnyObject
        let result = format.apply(image)
        let expected = resizer.resizeImage(image)
        XCTAssertTrue(result.isEqualPixelByPixel(expected))
    }

    // MARK: setImage

    func testSetImage_MemoryMiss() {
        let image = UIImage.imageWithColor(UIColor.greenColor())
        let key = self.name
        
        sut.hnk_setImage(image, key: key)
        
        XCTAssertNil(sut.image)
        XCTAssertEqual(sut.hnk_fetcher.key, key)
    }
    
    func testSetImage_MemoryHit() {
        let image = UIImage.imageWithColor(UIColor.greenColor())
        let key = self.name
        let cache = Haneke.sharedImageCache
        let format = sut.hnk_format
        cache.setValue(image, key, formatName: format.name)
        
        sut.hnk_setImage(image, key: key)
        
        XCTAssertTrue(sut.image!.isEqualPixelByPixel(image))
        XCTAssertTrue(sut.hnk_fetcher == nil)
    }
    
    func testSetImage_ImageSet_MemoryMiss() {
        let previousImage = UIImage.imageWithColor(UIColor.redColor())
        let image = UIImage.imageWithColor(UIColor.greenColor())
        let key = self.name
        sut.image = previousImage
        
        sut.hnk_setImage(image, key: key)
        
        XCTAssertEqual(sut.image!, previousImage)
        let fetcher = sut.hnk_fetcher
        XCTAssertEqual(sut.hnk_fetcher.key, key)
    }
    
    func testSetImage_UsingPlaceholder_MemoryMiss() {
        let placeholder = UIImage.imageWithColor(UIColor.yellowColor())
        let image = UIImage.imageWithColor(UIColor.greenColor())
        let key = self.name
        
        sut.hnk_setImage(image, key: key, placeholder: placeholder)
        
        XCTAssertEqual(sut.image!, placeholder)
        XCTAssertEqual(sut.hnk_fetcher.key, key)
    }
    
    func testSetImage_UsingPlaceholder_MemoryHit() {
        let placeholder = UIImage.imageWithColor(UIColor.yellowColor())
        let image = UIImage.imageWithColor(UIColor.greenColor())
        let key = self.name
        let cache = Haneke.sharedImageCache
        let format = sut.hnk_format
        cache.setValue(image, key, formatName: format.name)
        
        sut.hnk_setImage(image, key: key, placeholder: placeholder)
        
        XCTAssertTrue(sut.image!.isEqualPixelByPixel(image))
        XCTAssertTrue(sut.hnk_fetcher == nil)
    }
    
    func testSetImage_Success() {
        let image = UIImage.imageWithColor(UIColor.greenColor())
        let key = self.name
        sut.contentMode = .Center // No resizing
        let expectation = self.expectationWithDescription(self.name)
        
        sut.hnk_setImage(image, key: key, success:{resultImage in
            XCTAssertTrue(resultImage.isEqualPixelByPixel(image))
            expectation.fulfill()
        })
        
        XCTAssertNil(sut.image)
        XCTAssertEqual(sut.hnk_fetcher.key, key)
        self.waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    // MARK: setImageFromFetcher

    func testSetImageFromFetcher_MemoryMiss() {
        let image = UIImage.imageWithColor(UIColor.greenColor())
        let key = self.name
        let fetcher = SimpleFetcher<UIImage>(key: key, thing: image)
        
        sut.hnk_setImageFromFetcher(fetcher)

        XCTAssertNil(sut.image)
        XCTAssertTrue(sut.hnk_fetcher === fetcher)
    }
    
    func testSetImageFromFetcher_MemoryHit() {
        let image = UIImage.imageWithColor(UIColor.greenColor())
        let key = self.name
        let fetcher = SimpleFetcher<UIImage>(key: key, thing: image)
        let cache = Haneke.sharedImageCache
        let format = sut.hnk_format
        cache.setValue(image, key, formatName: format.name)
        
        sut.hnk_setImageFromFetcher(fetcher)
        
        XCTAssertTrue(sut.image!.isEqualPixelByPixel(image))
        XCTAssertTrue(sut.hnk_fetcher == nil)
    }
    
    func testSetImageFromFetcher_ImageSet_MemoryMiss() {
        let previousImage = UIImage.imageWithColor(UIColor.redColor())
        let image = UIImage.imageWithColor(UIColor.greenColor())
        let key = self.name
        let fetcher = SimpleFetcher<UIImage>(key: key, thing: image)
        sut.image = previousImage
        
        sut.hnk_setImageFromFetcher(fetcher)
        
        XCTAssertEqual(sut.image!, previousImage)
        XCTAssertTrue(sut.hnk_fetcher === fetcher)
    }

    func testSetImageFromFetcher_UsingPlaceholder_MemoryMiss() {
        let placeholder = UIImage.imageWithColor(UIColor.yellowColor())
        let image = UIImage.imageWithColor(UIColor.greenColor())
        let key = self.name
        let fetcher = SimpleFetcher<UIImage>(key: key, thing: image)
        
        sut.hnk_setImageFromFetcher(fetcher, placeholder:placeholder)
        
        XCTAssertEqual(sut.image!, placeholder)
        XCTAssertTrue(sut.hnk_fetcher === fetcher)
    }
    
    func testSetImageFromFetcher_UsingPlaceholder_MemoryHit() {
        let placeholder = UIImage.imageWithColor(UIColor.yellowColor())
        let image = UIImage.imageWithColor(UIColor.greenColor())
        let key = self.name
        let fetcher = SimpleFetcher<UIImage>(key: key, thing: image)
        let cache = Haneke.sharedImageCache
        let format = sut.hnk_format
        cache.setValue(image, key, formatName: format.name)
        
        sut.hnk_setImageFromFetcher(fetcher, placeholder:placeholder)
        
        XCTAssertTrue(sut.image!.isEqualPixelByPixel(image))
        XCTAssertTrue(sut.hnk_fetcher == nil)
    }
    
    func testSetImageFromFetcher_Success() {
        let image = UIImage.imageWithColor(UIColor.greenColor())
        let key = self.name
        let fetcher = SimpleFetcher<UIImage>(key: key, thing: image)
        sut.contentMode = .Center // No resizing
        let expectation = self.expectationWithDescription(self.name)
        
        sut.hnk_setImageFromFetcher(fetcher, success:{resultImage in
            XCTAssertTrue(resultImage.isEqualPixelByPixel(image))
            expectation.fulfill()
        })
        
        XCTAssertNil(sut.image)
        XCTAssertTrue(sut.hnk_fetcher === fetcher)
        self.waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testSetImageFromFetcher_Failure() {
        class MockFetcher<T : DataConvertible> : Fetcher<T>, Fetcher {
            typealias Fetched = T
            
            override init(key: String) {
                super.init(key: key)
            }
            
            override func fetchWithSuccess(success doSuccess : (T.Result) -> (), failure doFailure : ((NSError?) -> ())) {
                let error = errorWithCode(ImageViewTestError.Test, description: "test")
                doFailure(error)
            }
            
            override func cancelFetch() {}
            
        }
        
        let image = UIImage.imageWithColor(UIColor.greenColor())
        let key = self.name
        let fetcher = MockFetcher<UIImage>(key:key)
        let expectation = self.expectationWithDescription(self.name)
        
        sut.hnk_setImageFromFetcher(fetcher, failure:{error in
            XCTAssertTrue(errorIs(error, code: ImageViewTestError.Test))
            expectation.fulfill()
        })
        
        XCTAssertNil(sut.image)
        XCTAssertTrue(sut.hnk_fetcher === fetcher)
        self.waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    // MARK: setImageFromURL
    
    func testSetImageFromURL_MemoryMiss() {
        let URL = NSURL(string: "http://haneke.io")
        let fetcher = NetworkFetcher<UIImage>(URL: URL)
        
        sut.hnk_setImageFromURL(URL)
        
        XCTAssertNil(sut.image)
        XCTAssertEqual(sut.hnk_fetcher.key, fetcher.key)
    }
    
    func testSetImageFromURL_MemoryHit() {
        let image = UIImage.imageWithColor(UIColor.greenColor())
        let URL = NSURL(string: "http://haneke.io")
        let fetcher = NetworkFetcher<UIImage>(URL: URL)
        let cache = Haneke.sharedImageCache
        let format = sut.hnk_format
        cache.setValue(image, fetcher.key, formatName: format.name)
        
        sut.hnk_setImageFromURL(URL)
        
        XCTAssertTrue(sut.image!.isEqualPixelByPixel(image))
        XCTAssertTrue(sut.hnk_fetcher == nil)
    }
    
    func testSetImageFromURL_ImageSet_MemoryMiss() {
        let previousImage = UIImage.imageWithColor(UIColor.redColor())
        let URL = NSURL(string: "http://haneke.io")
        let fetcher = NetworkFetcher<UIImage>(URL: URL)
        sut.image = previousImage
        
        sut.hnk_setImageFromURL(URL)
        
        XCTAssertEqual(sut.image!, previousImage)
        XCTAssertEqual(sut.hnk_fetcher.key, fetcher.key)
    }
    
    func testSetImageFromURL_UsingPlaceholder_MemoryMiss() {
        let placeholder = UIImage.imageWithColor(UIColor.yellowColor())
        let URL = NSURL(string: "http://haneke.io")
        let fetcher = NetworkFetcher<UIImage>(URL: URL)
        
        sut.hnk_setImageFromURL(URL, placeholder: placeholder)
        
        XCTAssertEqual(sut.image!, placeholder)
        XCTAssertEqual(sut.hnk_fetcher.key, fetcher.key)
    }
    
    func testSetImageFromURL_UsingPlaceholder_MemoryHit() {
        let placeholder = UIImage.imageWithColor(UIColor.yellowColor())
        let image = UIImage.imageWithColor(UIColor.greenColor())
        let URL = NSURL(string: "http://haneke.io")
        let fetcher = NetworkFetcher<UIImage>(URL: URL)
        let cache = Haneke.sharedImageCache
        let format = sut.hnk_format
        cache.setValue(image, fetcher.key, formatName: format.name)
        
        sut.hnk_setImageFromURL(URL, placeholder: placeholder)
        
        XCTAssertTrue(sut.image!.isEqualPixelByPixel(image))
        XCTAssertTrue(sut.hnk_fetcher == nil)
    }
    
    func testSetImageFromURL_Success() {
        let image = UIImage.imageWithColor(UIColor.greenColor())
        OHHTTPStubs.stubRequestsPassingTest({ _ in
            return true
            }, withStubResponse: { _ in
                let data = UIImagePNGRepresentation(image)
                return OHHTTPStubsResponse(data: data, statusCode: 200, headers:nil)
        })
        let URL = NSURL(string: "http://haneke.io")
        let fetcher = NetworkFetcher<UIImage>(URL: URL)
        sut.contentMode = .Center // No resizing
        let expectation = self.expectationWithDescription(self.name)
        
        sut.hnk_setImageFromURL(URL, success:{resultImage in
            XCTAssertTrue(resultImage.isEqualPixelByPixel(image))
            expectation.fulfill()
        })
        
        XCTAssertNil(sut.image)
        XCTAssertEqual(sut.hnk_fetcher.key, fetcher.key)
        self.waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testSetImageFromURL_WhenPreviousSetImageFromURL() {
        let image = UIImage.imageWithColor(UIColor.greenColor())
        OHHTTPStubs.stubRequestsPassingTest({ _ in
            return true
            }, withStubResponse: { _ in
                let data = UIImagePNGRepresentation(image)
                return OHHTTPStubsResponse(data: data, statusCode: 200, headers:nil).responseTime(0.1)
        })
        let URL1 = NSURL(string: "http://haneke.io/1.png")
        sut.contentMode = .Center // No resizing
        sut.hnk_setImageFromURL(URL1, success:{_ in
            XCTFail("unexpected success")
            }, failure:{_ in
            XCTFail("unexpected failure")
        })
        let URL2 = NSURL(string: "http://haneke.io/2.png")
        let fetcher2 = NetworkFetcher<UIImage>(URL: URL2)
        let expectation = self.expectationWithDescription(self.name)
        
        sut.hnk_setImageFromURL(URL2, success:{resultImage in
            XCTAssertTrue(resultImage.isEqualPixelByPixel(image))
            expectation.fulfill()
        })
        
        XCTAssertNil(sut.image)
        XCTAssertEqual(sut.hnk_fetcher.key, fetcher2.key)
        self.waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testSetImageFromURL_Failure() {
        OHHTTPStubs.stubRequestsPassingTest({ _ in
            return true
            }, withStubResponse: { _ in
                let data = NSData.dataWithLength(100)
                return OHHTTPStubsResponse(data: data, statusCode: 404, headers:nil)
        })
        let URL = NSURL(string: "http://haneke.io")
        let fetcher = NetworkFetcher<UIImage>(URL: URL)
        let expectation = self.expectationWithDescription(self.name)
        
        sut.hnk_setImageFromURL(URL, failure:{error in
            XCTAssertTrue(errorIs(error, code: Haneke.NetworkError.InvalidStatusCode))
            expectation.fulfill()
        })
        
        XCTAssertNil(sut.image)
        XCTAssertEqual(sut.hnk_fetcher.key, fetcher.key)
        self.waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    // MARK: cancelSetImage
    
    func testCancelSetImage() {
        sut.hnk_cancelSetImage()
        
        XCTAssertTrue(sut.hnk_fetcher == nil)
    }
    
    func testCancelSetImage_AfterSetImage() {
        let URL = NSURL(string: "http://imgs.xkcd.com/comics/election.png")
        sut.hnk_setImageFromURL(URL, success: { _ in
            XCTFail("unexpected success")
        }, failure: { _ in
            XCTFail("unexpected failure")
        })
        
        sut.hnk_cancelSetImage()
        
        XCTAssertTrue(sut.hnk_fetcher == nil)
        self.waitFor(0.1)
    }*/

}
