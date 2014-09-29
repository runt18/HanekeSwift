//
//  UIImageView+Haneke.swift
//  Haneke
//
//  Created by Hermes Pique on 9/17/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit
import ObjectiveC
import Swift

public extension NSMapTable {
    
    subscript (key: AnyObject) -> AnyObject? {
        get {
            return objectForKey(key)
        }
        
        set (newValue) {
            if let newValue: AnyObject = newValue {
                setObject(newValue, forKey: key)
            } else {
                removeObjectForKey(key)
            }
        }
    }

}

public extension Haneke {
    public struct UIKit {
        
        public struct DefaultFormat {
            public static let DiskCapacity : Int = 10 * 1024 * 1024
            public static let CompressionQuality : Float = 0.75
        }
        
        static var associatedFetchers = NSMapTable.weakToStrongObjectsMapTable()
        
    }
}

public extension UIImageView {

    public var hnk_format : Format<UIImage> {
        let viewSize = self.bounds.size
            assert(viewSize.width > 0 && viewSize.height > 0, "[\(reflect(self).summary) \(__FUNCTION__)]: UImageView size is zero. Set its frame, call sizeToFit or force layout first.")
            let scaleMode = self.hnk_scaleMode
            return UIImageView.hnk_formatWithSize(viewSize, scaleMode: scaleMode)
    }
    
    func hnk_fetcher<T: Fetcher where T.Fetched == UIImage>() -> T? {
        return nil
    }
    
    /*public var hnk_testFetcher: Box<Fetcher>? {
        return nil
    }*/
    
    /*
    
    public func hnk_setImageFromURL(URL: NSURL, placeholder : UIImage? = nil, success doSuccess : ((UIImage) -> ())? = nil, failure doFailure : ((NSError?) -> ())? = nil) {
        let fetcher = NetworkFetcher<UIImage>(URL: URL)
        self.hnk_setImageFromFetcher(fetcher, placeholder: placeholder, success: doSuccess, failure: doFailure)
    }
    
    public func hnk_setImage(image: @autoclosure () -> UIImage, key : String, placeholder : UIImage? = nil, success doSuccess : ((UIImage) -> ())? = nil) {
        let fetcher = SimpleFetcher<UIImage>(key: key, thing: image)
        self.hnk_setImageFromFetcher(fetcher, placeholder: placeholder, success: doSuccess)
    }
    
    public func hnk_setImageFromFetcher(fetcher : Fetcher<UIImage>, placeholder : UIImage? = nil, success doSuccess : ((UIImage) -> ())? = nil, failure doFailure : ((NSError?) -> ())? = nil) {

        self.hnk_cancelSetImage()
        
        self.hnk_fetcher = fetcher
        
        let didSetImage = self.hnk_fetchImageForFetcher(fetcher, success: doSuccess, failure: doFailure)
        
        if didSetImage { return }
     
        if let placeholder = placeholder {
            self.image = placeholder
        }
    }
    
    public func hnk_cancelSetImage() {
        if let fetcher = self.hnk_fetcher {
            fetcher.cancelFetch()
            self.hnk_fetcher = nil
        }
    }
    
    // MARK: Internal
    */
    
    /*var hnk_fetcher: Fetcher! {
        return nil
    }*/
    
    /*
    // See: http://stackoverflow.com/questions/25907421/associating-swift-things-with-nsobject-instances
    var hnk_fetcher : Fetcher<UIImage>! {
        get {
            return Haneke.UIKit.associatedFetchers[self] as Fetcher<UIImage>!
        }
        
        set (fetcher) {
            Haneke.UIKit.associatedFetchers[self] = fetcher
        }
    }*/
    
    var hnk_scaleMode : ScaleMode {
        switch (self.contentMode) {
        case .ScaleToFill:
            return .Fill
        case .ScaleAspectFit:
            return .AspectFit
        case .ScaleAspectFill:
            return .AspectFill
        case .Redraw, .Center, .Top, .Bottom, .Left, .Right, .TopLeft, .TopRight, .BottomLeft, .BottomRight:
            return .None
            }
    }
    
    class func hnk_formatWithSize(size : CGSize, scaleMode : ScaleMode) -> Format<UIImage> {
        let name = "auto-\(size.width)x\(size.height)-\(scaleMode.toRaw())"
        let cache = Haneke.sharedImageCache
        if let (format,_,_) = cache.formats[name] {
            return format
        }
        
        var format = Format<UIImage>(name,
            diskCapacity: Haneke.UIKit.DefaultFormat.DiskCapacity) {
                let resizer = ImageResizer(size:size,
                scaleMode:scaleMode,
                compressionQuality: Haneke.UIKit.DefaultFormat.CompressionQuality)
                return resizer.resizeImage($0)
        }
        format.convertToData = {(image : UIImage) -> NSData in
            image.hnk_data(compressionQuality: Haneke.UIKit.DefaultFormat.CompressionQuality)
        }
        cache.addFormat(format)
        return format
    }
    
    /*
    func hnk_fetchImageForFetcher(fetcher : Fetcher<UIImage>, success doSuccess : ((UIImage) -> ())?, failure doFailure : ((NSError?) -> ())?) -> Bool {
        let format = self.hnk_format
        let cache = Haneke.sharedImageCache
        var animated = false
        let didSetImage = cache.fetchValueForFetcher(fetcher, formatName: format.name, success: {[weak self] (image) -> () in
            if let strongSelf = self {
                if strongSelf.hnk_shouldCancelForKey(fetcher.key) { return }
                
                strongSelf.hnk_setImage(image, animated:animated, success:doSuccess)
            }
        }, failure: {[weak self] (error) -> () in
            if let strongSelf = self {
                if strongSelf.hnk_shouldCancelForKey(fetcher.key) { return }
                
                strongSelf.hnk_fetcher = nil
                
                doFailure?(error)
            }
        })
        animated = true
        return didSetImage
    }
    
    func hnk_setImage(image : UIImage, animated : Bool, success doSuccess : ((UIImage) -> ())?) {
        self.hnk_fetcher = nil
        
        if let doSuccess = doSuccess {
            doSuccess(image)
        } else {
            let duration : NSTimeInterval = animated ? 0.1 : 0
            UIView.transitionWithView(self, duration: duration, options: .TransitionCrossDissolve, animations: {
                self.image = image
            }, completion: nil)
        }
    }
    
    func hnk_shouldCancelForKey(key:String) -> Bool {
        if self.hnk_fetcher?.key == key { return false }
        
        println("Cancelled set image for \(key.lastPathComponent)")
        return true
    }*/
    
}
