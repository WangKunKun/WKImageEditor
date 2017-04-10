//
//  WKImageView.swift
//  WKImageEditor
//
//  Created by 天下宅 on 2017/4/7.
//  Copyright © 2017年 天下宅. All rights reserved.
//

import UIKit

class WKImageView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var toCropImage:UIImage?//等待裁剪的图片
    var needScaleCrop = false//是否需要缩放裁剪
    var showMidLines = false//是否显示中间线
    var showCrossLines = false//是否显示裁剪框的交叉线
    var cropAspectRatio:CGFloat = 0.5//裁剪框的宽高比
    
    var cropAreaBorderLineColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)//裁剪边框的颜色
    var cropAreaBorderLineWidth:CGFloat = 0.5//裁剪边框的线宽
    var cropAreaCornerLineColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)//裁剪边框四个角的颜色
    var cropAreaCornerLineWidth:CGFloat = 0.5//裁剪边框四个角的线宽
    
    var cropAreaCornerHeight:CGFloat = 0.5//裁剪边框四个角的宽度
    var cropAreaCornerWidth:CGFloat = 0.5//裁剪边框四个角的高度
    var minSpace:CGFloat = 0.5//相邻角之间的最小距离
    
    var cropAreaCrossLineWidth:CGFloat = 0.5//裁剪框内交叉线的宽度
    var cropAreaCrossLineColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)//裁剪框内交叉线的颜色
    var cropAreaMidLineWidth:CGFloat = 0.5//裁剪框每条边中间线的长度
    var cropAreaMidLineHeight:CGFloat = 0.5//裁剪框每条边中间线的宽度
    var cropAreaMidLineColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)//裁剪框每条边中间线的颜色
    var maskColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)//裁剪区域蒙版颜色
    
    var cornerBorderInImage = false//裁剪边框的四个角是否超出图片显示
    var initialScaleFactor:CGFloat = 0.5
    
    private var cropMaskView = UIView()
    private var imageView = UIImageView()
    
    private var topLeftCorner:CornerView!
    private var topRightCorner:CornerView!
    private var bottomLeftCorner:CornerView!
    private var bottomRightCorner:CornerView!
    private var cropAreaView:CropAreaView!
    private var topLeftPan:UIPanGestureRecognizer!
    private var topRightPan:UIPanGestureRecognizer!
    private var bottomLeftPan:UIPanGestureRecognizer!
    private var bottomRightPan:UIPanGestureRecognizer!
    private var cropAreaPan:UIPanGestureRecognizer!
    private var cropAreaPinch:UIPinchGestureRecognizer!
    private var pinchOriSize:CGSize!
    private var cropAreaOriCenter:CGPoint!
    private var cropAreaOriFrame:CGRect!
    
    private var topMidLine:MidLineView!
    private var leftMidLine:MidLineView!
    private var bottomMidLine:MidLineView!
    private var rightMidLine:MidLineView!
    private var topMidPan:UIPanGestureRecognizer!
    private var bottomMidPan:UIPanGestureRecognizer!
    private var leftMidPan:UIPanGestureRecognizer!
    private var rightMidPan:UIPanGestureRecognizer!
    private var paddingLeftRight:CGFloat!
    private var paddingTopBottom:CGFloat!
    private var imageAspectRatio:CGFloat!
    private var cornerMargin:CGFloat!
    
    private var currentMinSpace:CGFloat!
    
    func setUp() {
        imageView = UIImageView.init(frame: self.bounds)
        imageView.contentMode = UIViewContentMode.scaleToFill
        imageView.isUserInteractionEnabled = true
        imageAspectRatio = 0
        
        self.addSubview(imageView)
        
        cropMaskView = UIView.init(frame: self.bounds)
        cropMaskView.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.8)
        cropMaskView.autoresizingMask = [UIViewAutoresizing.flexibleWidth,.flexibleHeight];
        imageView.addSubview(cropMaskView)
        
        let defaultColor = UIColor.init(white: 1, alpha: 0.8)
        cropAreaBorderLineColor = defaultColor
        cropAreaCornerLineColor = UIColor.white
        cropAreaBorderLineWidth = 2
        cropAreaCornerLineWidth = 4
        
        cropAreaCornerWidth = 20
        cropAreaCornerHeight = 40
        
        cropAspectRatio = 0
        minSpace = 10
        currentMinSpace = minSpace
        
        cropAreaCrossLineWidth = 2
        cropAreaCrossLineColor = defaultColor
        cropAreaMidLineWidth = 20
        cropAreaMidLineHeight = 4
        cropAreaMidLineColor = defaultColor
        
        cropAreaView = CropAreaView.init()
        cropAreaView.borderWidth = cropAreaBorderLineWidth
        cropAreaView.borderColor = cropAreaBorderLineColor
        cropAreaView.crossLineColor = cropAreaCrossLineColor
        cropAreaView.crossLineWidth = cropAreaCrossLineWidth
        cropAreaView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        imageView.addSubview(cropAreaView)
        
        cropAreaView.addObserver(self, forKeyPath: "frame", options: [.new,.initial], context: nil)
        cropAreaView.addObserver(self, forKeyPath: "center", options: [.new,.initial], context: nil)
        imageView.addObserver(self, forKeyPath: "frame", options: [.new,.initial], context: nil)
    }
    
    func createCorners() {
        topLeftCorner = CornerView.init(frame: CGRect.init(x: 0, y: 0, width: cropAreaCornerWidth, height: cropAreaCornerHeight), lineC: cropAreaCornerLineColor, lineW: cropAreaCornerLineWidth)
        topLeftCorner.autoresizingMask = [.flexibleBottomMargin,.flexibleRightMargin]
        topLeftCorner.cornerPosition = .topLeft
        
        
        topRightCorner = CornerView.init(frame: CGRect.init(x: imageView.wkWidth - cropAreaCornerWidth, y: 0, width: cropAreaCornerWidth, height: cropAreaCornerHeight), lineC: cropAreaCornerLineColor, lineW: cropAreaCornerLineWidth)
        topRightCorner.autoresizingMask = [.flexibleBottomMargin,.flexibleLeftMargin]
        topRightCorner.cornerPosition = .topRight
        
        bottomLeftCorner = CornerView.init(frame: CGRect.init(x: 0, y: imageView.wkHeight - cropAreaCornerHeight, width: cropAreaCornerWidth, height: cropAreaCornerHeight), lineC: cropAreaCornerLineColor, lineW: cropAreaCornerLineWidth)
        bottomLeftCorner.autoresizingMask = [.flexibleTopMargin,.flexibleRightMargin]
        bottomLeftCorner.cornerPosition = .bottomLeft
        
        bottomRightCorner = CornerView.init(frame: CGRect.init(x: imageView.wkWidth - cropAreaCornerWidth, y: imageView.wkHeight - cropAreaCornerHeight, width: cropAreaCornerWidth, height: cropAreaCornerHeight), lineC: cropAreaCornerLineColor, lineW: cropAreaCornerLineWidth)
        bottomRightCorner.autoresizingMask = [.flexibleTopMargin,.flexibleLeftMargin]
        bottomRightCorner.cornerPosition = .bottomRight
        
        topLeftCorner.relativeViewX = bottomLeftCorner
        topLeftCorner.relativeViewY = topRightCorner
        
        topRightCorner.relativeViewX = bottomRightCorner
        topRightCorner.relativeViewY = topLeftCorner
        
        bottomLeftCorner.relativeViewX = topLeftCorner
        bottomLeftCorner.relativeViewY = bottomRightCorner
        
        bottomRightCorner.relativeViewX = topRightCorner
        bottomRightCorner.relativeViewY = bottomLeftCorner
        
        imageView.addSubview(topLeftCorner)
        imageView.addSubview(topRightCorner)
        imageView.addSubview(bottomLeftCorner)
        imageView.addSubview(bottomRightCorner)
        
        
    }
    
    func resetCropAreaOnCornersFrameChanged()  {
        cropAreaView.frame = CGRect.init(x: topLeftCorner.wkLeft + self.cornerMargin, y: topLeftCorner.wkTop + self.cornerMargin, width: topRightCorner.wkRight - topLeftCorner.wkLeft - self.cornerMargin * 2, height: bottomLeftCorner.wkBottom - topLeftCorner.wkTop - self.cornerMargin * 2.0)
    }
    
    func bindPanGestures() {
        topLeftPan = UIPanGestureRecognizer.init(target: self, action: Selector(("handleCornerPan:")))
        topRightPan = UIPanGestureRecognizer.init(target: self, action: Selector(("handleCornerPan:")))
        bottomLeftPan = UIPanGestureRecognizer.init(target: self, action: Selector(("handleCornerPan:")))
        bottomRightPan = UIPanGestureRecognizer.init(target: self, action: Selector(("handleCornerPan:")))
        
        cropAreaPan = UIPanGestureRecognizer.init(target: self, action: Selector(("handleCropAreaPan:")))
        
        topLeftCorner.addGestureRecognizer(topLeftPan)
        topRightCorner.addGestureRecognizer(topRightPan)
        bottomLeftCorner.addGestureRecognizer(bottomLeftPan)
        bottomRightCorner.addGestureRecognizer(bottomRightPan)
        cropAreaView.addGestureRecognizer(cropAreaPan)
    }
    
    func commonInit()  {
        self.setUp()
        self.createCorners()
        self.resetCropAreaOnCornersFrameChanged()
        self.bindPanGestures()
    }
    
    
    //mark pan手势
    
    func handleCropAreaPinch(pinchGetsure:UIPinchGestureRecognizer) {
        switch pinchGetsure.state {
        case .began:
            pinchOriSize = cropAreaView.frame.size
        case .changed:
            fallthrough
        default:
            break
        }
    }
    
    func handleMidPan(panGesture:UIPanGestureRecognizer)  {
        let midLineView = panGesture.view as! MidLineView
        switch panGesture.state {
        case .began:
            cropAreaOriFrame = cropAreaView.frame
        case .changed:
            let translation = panGesture.translation(in: cropAreaView)
            switch midLineView.type {
            case .top:
                let minHeight = currentMinSpace + (cropAreaCornerHeight - cropAreaCornerLineWidth + cropAreaBorderLineWidth) * 2
                let maxHeight = cropAreaOriFrame.maxY - (cropAreaCornerLineWidth - cropAreaBorderLineWidth)
                let willHeight = min(max(minHeight, cropAreaOriFrame.height - translation.y), maxHeight)
                let deltaY = willHeight - cropAreaOriFrame.height
                cropAreaView.frame = CGRect.init(x: cropAreaOriFrame.minX, y: cropAreaOriFrame.minY - deltaY, width: cropAreaOriFrame.width, height: willHeight)
                
            case .bottom:
                let minHeight = currentMinSpace + (cropAreaCornerHeight - cropAreaCornerLineWidth + cropAreaBorderLineWidth) * 2
                let maxHeight = imageView.wkHeight
            default:
                break
            }
        default:
            break
        }
    }
    
    func handleCornerPan(panGesture:UIPanGestureRecognizer) {
        
    }
    
    func handleCropAreaPan(panGesture:UIPanGestureRecognizer) {
        
        switch panGesture.state {
        case .began:
            cropAreaOriCenter = cropAreaView.center
        case .changed:
            
            let v:CGFloat = (cornerBorderInImage ? 1.0 : 0.0)
            
            let translation = panGesture.translation(in: imageView)
            let willCenter = CGPoint.init(x: cropAreaOriCenter.x + translation.x, y: cropAreaOriCenter.y + translation.y)
            let centerMinX = cropAreaView.wkWidth / 2.0 + self.cornerMargin * v
            let centerMaxX = imageView.wkWidth - cropAreaView.wkWidth / 2.0 - self.cornerMargin * v
            let centerMinY = cropAreaView.wkHeight / 2.0 + self.cornerMargin * v
            let centerMaxY = imageView.wkHeight - cropAreaView.wkHeight / 2.0 - self.cornerMargin * v
            
            cropAreaView.center = CGPoint.init(x: min(max(centerMinX, willCenter.x), centerMaxX) , y: min(max(centerMinY, willCenter.y), centerMaxY))
        default:
            break
        }
        
    }
    

    deinit {
        cropAreaView.removeObserver(self, forKeyPath: "frame")
        cropAreaView.removeObserver(self, forKeyPath: "center")
        imageView.removeObserver(self, forKeyPath: "frame")
    }
}
