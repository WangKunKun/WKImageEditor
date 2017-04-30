//
//  WKImageExtension.swift
//  WKImageEditor
//
//  Created by 天下宅 on 2017/3/31.
//  Copyright © 2017年 天下宅. All rights reserved.
//

import Foundation
import UIKit

enum WKCropAreaCornerPosition
{
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

enum WKMidLineType
{
    case top
    case bottom
    case left
    case right
}



extension UIImage
{
    func fixOrientation() -> UIImage?
    {
        if self.imageOrientation == .up {
            return self;
        }
        
        var transform = CGAffineTransform.identity;
        
        switch self.imageOrientation {
        case .down:
            fallthrough
        case .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height);
            transform = transform.rotated(by: CGFloat(M_PI));
        case .left:
            fallthrough
        case .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0);
            transform = transform.rotated(by: CGFloat(M_PI_2));
        case .right:
            fallthrough
        case .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-M_PI_2));
        default:
            break;
        }
        
        switch self.imageOrientation {
        case .upMirrored:
            fallthrough
        case .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        case .leftMirrored:
            fallthrough
        case .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        
        default:
            break
        }
        
        let ctx = CGContext(data: nil , width: 200, height: 130, bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue);
        ctx!.concatenate(transform);
        
        switch self.imageOrientation {
        case .left:
            fallthrough
        case .leftMirrored:
            fallthrough
        case .rightMirrored:
            fallthrough
        case .right:
            ctx?.draw(self.cgImage!, in: CGRect.init(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
            ctx?.draw(self.cgImage!, in: CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        
        let cgImge =  ctx!.makeImage();
        let result = UIImage.init(cgImage: cgImge!);
        
        return result;
    }
    
    func imageAtRect(rect:CGRect) -> UIImage {
        let fixedImage = self.fixOrientation()
        let cgImge = (fixedImage?.cgImage!)!.cropping(to: rect);
        let result = UIImage.init(cgImage: cgImge!)
        return result
    }
}
