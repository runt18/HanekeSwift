//
//  UIImage+Haneke.swift
//  Haneke
//
//  Created by Hermes Pique on 8/10/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit

extension UIImage {

    func hnk_imageByScalingToSize(toSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(toSize, !hnk_hasAlpha, 0.0)
        drawInRect(CGRect(origin: CGPointZero, size: toSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    var hnk_hasAlpha: Bool {
        if let cgImage = CGImage {
            switch CGImageGetAlphaInfo(cgImage) {
            case .First, .Last, .PremultipliedFirst, .PremultipliedLast, .Only:
                return true
            case .None, .NoneSkipFirst, .NoneSkipLast:
                return false
            }
        }
        return (CIImage != nil)
    }
    
    func hnk_data(compressionQuality: Float = 1.0) -> NSData! {
        let hasAlpha = self.hnk_hasAlpha
        let data = hasAlpha ? UIImagePNGRepresentation(self) : UIImageJPEGRepresentation(self, CGFloat(compressionQuality))
        return data
    }
    
    func hnk_decompressedImage() -> UIImage {
        let originalImageRef = CGImage
        let originalBitmapInfo = CGImageGetBitmapInfo(originalImageRef)
        
        // See: http://stackoverflow.com/questions/23723564/which-cgimagealphainfo-should-we-use
        var alphaInfo: CGImageAlphaInfo
        switch (CGImageGetAlphaInfo(originalImageRef)) {
        case .None:
            alphaInfo = .NoneSkipFirst
        case .PremultipliedFirst, .PremultipliedLast, .NoneSkipFirst, .NoneSkipLast:
            alphaInfo = .PremultipliedFirst
        case .Only, .Last, .First: // Unsupported
            return self
        }
        
        let bitmapInfo = CGBitmapInfo(alphaInfo.toRaw()) | .ByteOrder32Little
        
        //kCGImageAlphaPremultipliedFirst
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let pixelSize = CGSize(width: size.width * scale, height: size.height * scale)
        if let context = CGBitmapContextCreate(nil, UInt(pixelSize.width), UInt(pixelSize.height), 8, 0, colorSpace, bitmapInfo) {
            let imageRect = CGRect(origin: CGPointZero, size: pixelSize)
            
            UIGraphicsPushContext(context)
            
            // Flip coordinate system. See: http://stackoverflow.com/questions/506622/cgcontextdrawimage-draws-image-upside-down-when-passed-uiimage-cgimage
            CGContextTranslateCTM(context, 0, pixelSize.height)
            CGContextScaleCTM(context, 1.0, -1.0)
            
            // UIImage and drawInRect takes into account image orientation, unlike CGContextDrawImage.
            drawInRect(imageRect)
            UIGraphicsPopContext()
            
            let decompressedImageRef = CGBitmapContextCreateImage(context)
            return UIImage(CGImage: decompressedImageRef, scale: scale, orientation:UIImageOrientation.Up)
        } else {
            return self
        }
    }
    
}

extension UIImage: Decompressible {

    public func asDecompressedValue() -> Self {
        let originalImageRef = CGImage
        let originalBitmapInfo = CGImageGetBitmapInfo(originalImageRef)
        
        // See: http://stackoverflow.com/questions/23723564/which-cgimagealphainfo-should-we-use
        var alphaInfo: CGImageAlphaInfo
        switch (CGImageGetAlphaInfo(originalImageRef)) {
        case .None:
            alphaInfo = .NoneSkipFirst
        case .PremultipliedFirst, .PremultipliedLast, .NoneSkipFirst, .NoneSkipLast:
            alphaInfo = .PremultipliedFirst
        case .Only, .Last, .First: // Unsupported
            return self
        }
        
        let bitmapInfo = CGBitmapInfo(alphaInfo.toRaw()) | .ByteOrder32Little
        
        //kCGImageAlphaPremultipliedFirst
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let pixelSize = CGSize(width: size.width * scale, height: size.height * scale)
        if let context = CGBitmapContextCreate(nil, UInt(pixelSize.width), UInt(pixelSize.height), 8, 0, colorSpace, bitmapInfo) {
            let imageRect = CGRect(origin: CGPointZero, size: pixelSize)
            
            UIGraphicsPushContext(context)
            
            // Flip coordinate system. See: http://stackoverflow.com/questions/506622/cgcontextdrawimage-draws-image-upside-down-when-passed-uiimage-cgimage
            CGContextTranslateCTM(context, 0, pixelSize.height)
            CGContextScaleCTM(context, 1.0, -1.0)
            
            // UIImage and drawInRect takes into account image orientation, unlike CGContextDrawImage.
            drawInRect(imageRect)
            UIGraphicsPopContext()
            
            let decompressedImageRef = CGBitmapContextCreateImage(context)
            return self.dynamicType(CGImage: decompressedImageRef, scale: scale, orientation:UIImageOrientation.Up)
        } else {
            return self
        }
    }
    
}



