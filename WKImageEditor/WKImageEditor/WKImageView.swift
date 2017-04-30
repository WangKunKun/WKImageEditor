//
//  WKImageView.swift
//  WKImageEditor
//
//  Created by 天下宅 on 2017/4/7.
//  Copyright © 2017年 天下宅. All rights reserved.
//

import UIKit

let midLineInteractWidth:CGFloat = 44
let midLineInteractHeight:CGFloat = 44

class WKImageView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var toCropImage:UIImage?//等待裁剪的图片
    {
        didSet{
            if toCropImage != nil {
                imageAspectRatio = toCropImage!.size.width / toCropImage!.size.height
            }
            imageView.image = toCropImage
            self.resetImageView()
            self.resetCropAreaByAspectRatio()
        }
    }
    
    var needScaleCrop = false//是否需要缩放裁剪
    {
        willSet{
            if !needScaleCrop && newValue {
                cropAreaPinch = UIPinchGestureRecognizer.init(target: self, action: #selector(handleCropAreaPinch(pinchGetsure:)))
                cropAreaView.addGestureRecognizer(cropAreaPinch)
            }
            else if needScaleCrop && !newValue
            {
                cropAreaView.removeGestureRecognizer(cropAreaPinch)
                cropAreaPinch = nil
            }
        }
    }
    var showMidLines = false//是否显示中间线
        {
        willSet{
            if cropAspectRatio == 0 {
                if !showMidLines && newValue {
                    self.createMidLines()
                    self.resetMidLines()
                }
                else if showMidLines && !newValue
                {
                    self.removeMidLines()
                }
            }
        }
    }
    var showCrossLines = false//是否显示裁剪框的交叉线
        {
        didSet{
            cropAreaView.showCrossLines = showCrossLines
        }
    }
    var cropAspectRatio:CGFloat = 0.5//裁剪框的宽高比
        {
        willSet{
           cropAspectRatio =  max(newValue, 0)
        }
        didSet{
            self.resetCropAreaByAspectRatio()
        }
    }
    
    var cropAreaBorderLineColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)//裁剪边框的颜色
    {
        didSet{
            cropAreaView.borderColor = cropAreaBorderLineColor
        }
    }
    var cropAreaBorderLineWidth:CGFloat = 0.5//裁剪边框的线宽
    {
        didSet{
            cropAreaView.borderWidth = cropAreaBorderLineWidth
            self.resetCropAreaOnCornersFrameChanged()
        }
    }
    var cropAreaCornerLineColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)//裁剪边框四个角的颜色
    {
        didSet{
            topLeftCorner?.lineColor = cropAreaCornerLineColor
            topRightCorner?.lineColor = cropAreaCornerLineColor
            bottomLeftCorner?.lineColor = cropAreaCornerLineColor
            bottomRightCorner?.lineColor = cropAreaCornerLineColor

        }
    }
    var cropAreaCornerLineWidth:CGFloat = 0.5//裁剪边框四个角的线宽
        {
        didSet{
            topLeftCorner?.lineWidth = cropAreaCornerLineWidth
            topRightCorner?.lineWidth = cropAreaCornerLineWidth
            bottomLeftCorner?.lineWidth = cropAreaCornerLineWidth
            bottomRightCorner?.lineWidth = cropAreaCornerLineWidth
            self.resetCropAreaByAspectRatio()
        }
    }
    
    var cropAreaCornerHeight:CGFloat = 0.5//裁剪边框四个角的宽度
        {
        didSet{
            self.resetCornersOnSizeChanged()
        }
    }
    var cropAreaCornerWidth:CGFloat = 0.5//裁剪边框四个角的高度
        {
        didSet{
            self.resetCornersOnSizeChanged()
        }
    }
    var minSpace:CGFloat = 0.5
    {
        didSet{
            currentMinSpace = minSpace
        }
    }//相邻角之间的最小距离
    
    var cropAreaCrossLineWidth:CGFloat = 0.5//裁剪框内交叉线的宽度
    {
        didSet{
            cropAreaView.crossLineWidth = cropAreaCrossLineWidth
        }
    }
    
    var cropAreaCrossLineColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)//裁剪框内交叉线的颜色
    {
        didSet{
            cropAreaView.crossLineColor = cropAreaCrossLineColor
        }
    }
    var cropAreaMidLineWidth:CGFloat = 0.5//裁剪框每条边中间线的长度
    {
        didSet{
            topMidLine?.lineWidth = cropAreaMidLineWidth
            bottomMidLine?.lineWidth = cropAreaMidLineWidth
            leftMidLine?.lineWidth = cropAreaMidLineWidth
            rightMidLine?.lineWidth = cropAreaMidLineWidth
            if showMidLines {
                self.resetMidLines()
            }
        }
    }
    var cropAreaMidLineHeight:CGFloat = 0.5//裁剪框每条边中间线的宽度
        {
        didSet{
            topMidLine?.lineHeight = cropAreaMidLineHeight
            bottomMidLine?.lineHeight = cropAreaMidLineHeight
            leftMidLine?.lineHeight = cropAreaMidLineHeight
            rightMidLine?.lineHeight = cropAreaMidLineHeight
            if showMidLines {
                self.resetMidLines()
            }
        }
    }
    var cropAreaMidLineColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)//裁剪框每条边中间线的颜色
    {
        didSet{
            topMidLine?.lineColor = cropAreaMidLineColor
            bottomMidLine?.lineColor = cropAreaMidLineColor
            leftMidLine?.lineColor = cropAreaMidLineColor
            rightMidLine?.lineColor = cropAreaMidLineColor

        }
    }
    var maskColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)//裁剪区域蒙版颜色
    {
        didSet{
            cropMaskView.backgroundColor = maskColor
        }
    }
    
    var cornerBorderInImage = false//裁剪边框的四个角是否超出图片显示
        {
        didSet{
            self.resetCropAreaByAspectRatio()
        }
    }
    var initialScaleFactor:CGFloat = 0.5
    {
        willSet(newValue){
            initialScaleFactor = min(1.0, newValue)
        }
    }
    
    
    
    
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
    {
        get{
            return cropAreaCornerLineWidth - cropAreaBorderLineWidth
        }
    }
    
    
    private var currentMinSpace:CGFloat!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()

    }
    
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
        
        cropAreaView = CropAreaView.init()
        cropAreaView.borderWidth = cropAreaBorderLineWidth
        cropAreaView.borderColor = cropAreaBorderLineColor
        cropAreaView.crossLineColor = cropAreaCrossLineColor
        cropAreaView.crossLineWidth = cropAreaCrossLineWidth
        cropAreaView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        imageView.addSubview(cropAreaView)
        self.createCorners()//提前创建避免崩溃
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
        

        
        //监听frame失效 因为cropareaView覆写了frame 所以监听失效 
        /*解决方案    1.不监听，修改的地方直接调用方法
                    2.闭包书写 让cropareaview复写时调用，效果不理想 摒弃
                    3.取消cropareaview的复写，所有相关这边来实现
        此处用的第三种方案
         */
        cropAreaView.addObserver(self, forKeyPath: "frame", options: [.new,.initial], context: nil)
        cropAreaView.addObserver(self, forKeyPath: "bounds", options: [.new,.initial], context: nil)
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
        topLeftPan = UIPanGestureRecognizer.init(target: self, action: #selector(handleCornerPan(panGesture:)))
        topRightPan = UIPanGestureRecognizer.init(target: self, action: #selector(handleCornerPan(panGesture:)))
        bottomLeftPan = UIPanGestureRecognizer.init(target: self, action: #selector(handleCornerPan(panGesture:)))
        bottomRightPan = UIPanGestureRecognizer.init(target: self, action: #selector(handleCornerPan(panGesture:)))
        
        cropAreaPan = UIPanGestureRecognizer.init(target: self, action: #selector(handleCropAreaPan(panGesture:)))
        
        topLeftCorner.addGestureRecognizer(topLeftPan)
        topRightCorner.addGestureRecognizer(topRightPan)
        bottomLeftCorner.addGestureRecognizer(bottomLeftPan)
        bottomRightCorner.addGestureRecognizer(bottomRightPan)
        cropAreaView.addGestureRecognizer(cropAreaPan)
    }
    
    func commonInit()  {
        
        self.setUp()
        self.resetCropAreaOnCornersFrameChanged()
        self.bindPanGestures()
    }
    
    
    //mark pan手势
    
    func handleCropAreaPinch(pinchGetsure:UIPinchGestureRecognizer) {
        switch pinchGetsure.state {
        case .began:
            pinchOriSize = cropAreaView.frame.size
        case .changed:
            self.resetCropAreaByScaleFactor(scaleFactor: pinchGetsure.scale)
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
                let maxHeight = imageView.wkHeight - cropAreaOriFrame.minY - (cropAreaCornerLineWidth - cropAreaBorderLineWidth)
                let willHeight = min(max(minHeight, cropAreaOriFrame.height + translation.y), maxHeight)
                cropAreaView.frame = CGRect.init(x: cropAreaOriFrame.minX, y: cropAreaOriFrame.minY, width: cropAreaOriFrame.width, height: willHeight)
            case .left:
                let minWidth = currentMinSpace + (cropAreaCornerWidth - cropAreaCornerLineWidth + cropAreaBorderLineWidth) * 2
                let maxWidth = cropAreaOriFrame.maxX - (cropAreaCornerLineWidth - cropAreaBorderLineWidth)
                let willWidth = min(max(minWidth, cropAreaOriFrame.width - translation.x), maxWidth)
                let deltaX = willWidth - cropAreaOriFrame.width
                cropAreaView.frame = CGRect.init(x: cropAreaOriFrame.minX - deltaX, y: cropAreaOriFrame.minY, width: willWidth, height: cropAreaOriFrame.height)
            case .right:
                let minWidth = currentMinSpace + (cropAreaCornerWidth - cropAreaCornerLineWidth + cropAreaBorderLineWidth) * 2
                let maxWidth = imageView.wkWidth - cropAreaOriFrame.minX - (cropAreaCornerLineWidth - cropAreaBorderLineWidth)
                let willWidth = min(max(minWidth, cropAreaOriFrame.width + translation.x), maxWidth)
                cropAreaView.frame = CGRect.init(x: cropAreaOriFrame.minX , y: cropAreaOriFrame.minY, width: willWidth, height: cropAreaOriFrame.height)

            }
            
            //监听frame失效  外部强行调用
//            if showMidLines {
//                self.resetMidLines()
//            }
//            self.resetCropTransparentArea()
            
            self.resetCornersOnCropAreaFrameChanged()
        default:
            break
        }
    }
    
    func handleCornerPan(panGesture:UIPanGestureRecognizer) {
        let panView = panGesture.view as! CornerView
        let relativeViewX = panView.relativeViewX!
        let relativeViewY = panView.relativeViewY!
        
        let locationInImageView = panGesture.location(in: imageView)
        
        let xFactor:CGFloat = relativeViewY.wkLeft > panView.wkLeft ? -1 : 1
        let yFactor:CGFloat = relativeViewX.wkTop > panView.wkTop ? -1 : 1
        var approachAspectRatio:CGFloat = 0
        if panView == topLeftCorner
        {
            approachAspectRatio = (panView.wkLeft + self.cornerMargin) / (panView.wkTop + self.cornerMargin)
        }
        else if panView == topRightCorner
        {
            approachAspectRatio = (imageView.wkWidth - panView.wkBottom + self.cornerMargin) / (panView.wkTop + self.cornerMargin)
        }
        else if panView == bottomLeftCorner
        {
            approachAspectRatio = (panView.wkLeft + self.cornerMargin) / (imageView.wkHeight - panView.wkBottom + self.cornerMargin)
        }
        else if panView == bottomRightCorner
        {
            approachAspectRatio = (imageView.wkWidth - panView.wkRight + self.cornerMargin) / (imageView.wkHeight - panView.wkBottom + self.cornerMargin)
        }
        
        let fixValue:CGFloat = (cornerBorderInImage ? 0 : 1)
        
        let tmpX = xFactor < 0 ? relativeViewY.center.x + cropAreaCornerWidth / 2.0 - self.cornerMargin * 2 + self.cornerMargin * fixValue : imageView.wkWidth - relativeViewY.center.x + cropAreaCornerWidth / 2.0 - self.cornerMargin * 2 + self.cornerMargin * fixValue;
        
        let tmpY = yFactor < 0 ? relativeViewX.center.y + cropAreaCornerHeight / 2.0 - self.cornerMargin * 2 + self.cornerMargin * fixValue : imageView.wkHeight - relativeViewX.center.y + cropAreaCornerHeight / 2.0 - self.cornerMargin * 2 + self.cornerMargin * fixValue
        
        
        var spaceX = min(max((locationInImageView.x - relativeViewY.center.x) * xFactor + cropAreaCornerWidth - self.cornerMargin * 2,currentMinSpace + cropAreaCornerWidth * 2 - self.cornerMargin * 2), tmpX)
        
        var spaceY = min(max((locationInImageView.y - relativeViewX.center.y) * yFactor + cropAreaCornerHeight - self.cornerMargin * 2,currentMinSpace + cropAreaCornerHeight * 2 - self.cornerMargin * 2), tmpY)
        
        if cropAspectRatio > 0 {
            if cropAspectRatio >= approachAspectRatio {
                spaceY = max(spaceX / cropAspectRatio, currentMinSpace + cropAreaCornerHeight * 2 - self.cornerMargin * 2)
                spaceX = spaceY * cropAspectRatio
            }
            else
            {
                spaceX = max(spaceY * cropAspectRatio, currentMinSpace + cropAreaCornerWidth * 2 - self.cornerMargin * 2)
                spaceY = spaceX / cropAspectRatio
            }
        }
        
        let centerX = (spaceX - cropAreaCornerWidth + self.cornerMargin * 2) * xFactor + relativeViewY.center.x
        let centerY = (spaceY - cropAreaCornerHeight + self.cornerMargin * 2) * yFactor + relativeViewX.center.y
        
        panView.center = CGPoint.init(x: centerX, y: centerY)
        relativeViewX.frame = CGRect.init(x: panView.wkLeft, y: relativeViewX.wkTop, width: relativeViewX.wkWidth, height: relativeViewX.wkHeight)
        relativeViewY.frame = CGRect.init(x: relativeViewY.wkLeft, y: panView.wkTop, width: relativeViewY.wkWidth, height: relativeViewY.wkHeight)
        
        self.resetCropAreaOnCornersFrameChanged()
        //监听失效 外部处理
//        if showMidLines {
//            self.resetMidLines()
//        }
//        self.resetCropTransparentArea()
        
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
            self.resetCornersOnCropAreaFrameChanged()
            //监听失效 外部处理
//            if showMidLines {
//                self.resetMidLines()
//            }
//            self.resetCropTransparentArea()
        default:
            break
        }
        
    }
    
    func resetCropAreaByScaleFactor(scaleFactor:CGFloat) {
        var center = cropAreaView.center
        let tmpCornerMargin = self.cornerMargin * (cornerBorderInImage ? 1 : 0)
        var width = pinchOriSize.width * scaleFactor
        var height = pinchOriSize.height * scaleFactor
        let widthMax = min(imageView.wkWidth - center.x - tmpCornerMargin, center.x - tmpCornerMargin) * 2
        let widthMin = currentMinSpace + cropAreaCornerWidth * 2.0 - tmpCornerMargin * 2.0
        let heightMax = min(imageView.wkHeight - center.y - tmpCornerMargin, center.y - tmpCornerMargin) * 2
        let heightMin = widthMin
        
        var isMinimum = false
        if cropAspectRatio > 1 {
            if height <= heightMin {
                height = heightMin
                width = height * cropAspectRatio
                isMinimum = true
            }
        }
        else
        {
            if width <= widthMin
            {
                width = widthMin
                height = width / (cropAspectRatio == 0 ? 1: cropAspectRatio)
                isMinimum = true
            }
        }
        
        if !isMinimum {
            if cropAspectRatio == 0 {
                if width >= widthMax {
                    width = min(width, imageView.wkWidth - 2 * tmpCornerMargin)
                    center.x = center.x > imageView.wkWidth / 2.0 ? imageView.wkWidth - width / 2.0 - tmpCornerMargin : width / 2.0 + tmpCornerMargin
                }
                if height > heightMax {
                    height = min(height, imageView.wkHeight - 2 * tmpCornerMargin)
                    center.y = center.y > imageView.wkWidth / 2.0 ? imageView.wkHeight - height / 2.0 - tmpCornerMargin : height / 2.0 + tmpCornerMargin
                }
            }
            else if imageAspectRatio > cropAspectRatio
            {
                if height >= heightMax {
                    height = min(height, imageView.wkHeight - 2 * tmpCornerMargin)
                    center.y = center.y > imageView.wkWidth / 2.0 ? imageView.wkHeight - height / 2.0 - tmpCornerMargin : height / 2.0 + tmpCornerMargin
                }
                width = height * cropAspectRatio
                if width > widthMax
                {
                    center.x = center.x > imageView.wkWidth / 2.0 ? imageView.wkWidth - width / 2.0 - tmpCornerMargin : width / 2.0 + tmpCornerMargin
                }
            }
            else
            {
                if width >= widthMax {
                    width = min(width, imageView.wkWidth - 2 * tmpCornerMargin)
                    center.x = center.x > imageView.wkWidth / 2.0 ? imageView.wkWidth - width / 2.0 - tmpCornerMargin : width / 2.0 + tmpCornerMargin
                }
                height = width / cropAspectRatio
                if height > heightMax {
                    center.y = center.y > imageView.wkWidth / 2.0 ? imageView.wkHeight - height / 2.0 - tmpCornerMargin : height / 2.0 + tmpCornerMargin
                }
            }
        }
        cropAreaView.bounds = CGRect.init(x: 0, y: 0, width: width, height: height)
        cropAreaView.center = center
        self.resetCornersOnCropAreaFrameChanged()
    }
    
    func resetCornersOnCropAreaFrameChanged() {
        topLeftCorner.frame = CGRect.init(x: cropAreaView.wkLeft - cropAreaCornerLineWidth + cropAreaBorderLineWidth, y: cropAreaView.wkTop - cropAreaCornerLineWidth + cropAreaBorderLineWidth, width: cropAreaCornerWidth, height: cropAreaCornerHeight)
        topRightCorner.frame = CGRect.init(x: cropAreaView.wkRight - cropAreaCornerWidth + cropAreaCornerLineWidth - cropAreaBorderLineWidth, y: cropAreaView.wkTop - cropAreaCornerLineWidth + cropAreaBorderLineWidth, width: cropAreaCornerWidth, height: cropAreaCornerHeight)
        bottomLeftCorner.frame = CGRect.init(x: cropAreaView.wkLeft - cropAreaCornerLineWidth + cropAreaBorderLineWidth, y: cropAreaView.wkBottom - cropAreaCornerHeight + cropAreaCornerLineWidth - cropAreaBorderLineWidth, width: cropAreaCornerWidth, height: cropAreaCornerHeight)
        bottomRightCorner.frame = CGRect.init(x:  cropAreaView.wkRight - cropAreaCornerWidth + cropAreaCornerLineWidth - cropAreaBorderLineWidth, y: cropAreaView.wkBottom - cropAreaCornerHeight + cropAreaCornerLineWidth - cropAreaBorderLineWidth, width: cropAreaCornerWidth, height: cropAreaCornerHeight)

    }
    
    func resetCropTransparentArea(){
        let path = UIBezierPath.init(rect: imageView.bounds)
        let clearPath = UIBezierPath.init(rect: cropAreaView.frame).reversing()
        path.append(clearPath)
        var shapeLayer = cropMaskView.layer.mask as? CAShapeLayer
        if !(shapeLayer != nil)
        {
            shapeLayer = CAShapeLayer()
            cropMaskView.layer.mask = shapeLayer
        }
        shapeLayer?.path = path.cgPath
    }
    
    func resetMinSpaceIfNeeded()
    {
        let willMinSpace = min(cropAreaView.wkWidth - cropAreaCornerWidth * 2 + self.cornerMargin * 2, cropAreaView.wkHeight - cropAreaCornerHeight * 2 + self.cornerMargin * 2)
        currentMinSpace = min(willMinSpace, minSpace)
    }
    
    func resetCornersOnSizeChanged() {
        topLeftCorner.updateSizeWithWidth(width: cropAreaCornerWidth, height: cropAreaCornerHeight)
        topRightCorner.updateSizeWithWidth(width: cropAreaCornerWidth, height: cropAreaCornerHeight)
        bottomLeftCorner.updateSizeWithWidth(width: cropAreaCornerWidth, height: cropAreaCornerHeight)
        bottomRightCorner.updateSizeWithWidth(width: cropAreaCornerWidth, height: cropAreaCornerHeight)

    }
    
    func createMidLines() {
        if (topMidLine != nil) && (bottomMidLine != nil) && (leftMidLine != nil) && (rightMidLine != nil) {
            return
        }
        
        topMidLine = MidLineView.init(lineW: cropAreaMidLineWidth, lineH: cropAreaMidLineHeight, lineC: cropAreaMidLineColor)
        topMidLine.type = .top
        
        bottomMidLine = MidLineView.init(lineW: cropAreaMidLineWidth, lineH: cropAreaMidLineHeight, lineC: cropAreaMidLineColor)
        bottomMidLine.type = .bottom
        
        leftMidLine = MidLineView.init(lineW: cropAreaMidLineWidth, lineH: cropAreaMidLineHeight, lineC: cropAreaMidLineColor)
        leftMidLine.type = .right
        
        rightMidLine = MidLineView.init(lineW: cropAreaMidLineWidth, lineH: cropAreaMidLineHeight, lineC: cropAreaMidLineColor)
        rightMidLine.type = .right
        
        topMidPan = UIPanGestureRecognizer.init(target: self, action: #selector(handleMidPan(panGesture:)))
        bottomMidPan = UIPanGestureRecognizer.init(target: self, action: #selector(handleMidPan(panGesture:)))
        leftMidPan = UIPanGestureRecognizer.init(target: self, action: #selector(handleMidPan(panGesture:)))
        rightMidPan = UIPanGestureRecognizer.init(target: self, action: #selector(handleMidPan(panGesture:)))
        topMidLine.addGestureRecognizer(topMidPan)
        bottomMidLine.addGestureRecognizer(bottomMidPan)
        leftMidLine.addGestureRecognizer(leftMidPan)
        rightMidLine.addGestureRecognizer(rightMidPan)
        
        cropAreaView.addSubview(topMidLine)
        cropAreaView.addSubview(bottomMidLine)
        cropAreaView.addSubview(leftMidLine)
        cropAreaView.addSubview(rightMidLine)
        
    }
    
    func removeMidLines() {
        topMidLine.removeFromSuperview()
        bottomMidLine.removeFromSuperview()
        leftMidLine.removeFromSuperview()
        rightMidLine.removeFromSuperview()
        
        topMidLine = nil
        bottomMidLine = nil
        leftMidLine = nil
        rightMidLine = nil
    }
    
    func resetImageView() {
        
        self.layoutIfNeeded()//xib sb 控件 需先调用才能得到实际大小

        
        let selfAspectRatio = self.wkWidth / self.wkHeight

        if imageAspectRatio > selfAspectRatio {
            paddingLeftRight = 0
            paddingTopBottom = floor((self.wkHeight - self.wkWidth / imageAspectRatio) / 2.0)
            imageView.frame = CGRect.init(x: 0, y: paddingTopBottom, width: self.wkWidth, height: floor(self.wkWidth / imageAspectRatio))
        }
        else
        {
            paddingTopBottom = 0
            paddingLeftRight = floor((self.wkWidth - self.wkHeight * imageAspectRatio) / 2.0)
            imageView.frame = CGRect.init(x: paddingLeftRight, y: 0, width: floor(self.wkHeight * imageAspectRatio), height: self.wkHeight)
            
        }
        
    }
    
    func resetMidLines()  {
        let lineMargin = cropAreaMidLineHeight / 2.0 - cropAreaBorderLineWidth
        
        if topMidLine != nil && bottomMidLine != nil && leftMidLine != nil && rightMidLine != nil{
            topMidLine.frame = CGRect.init(x: (cropAreaView.wkWidth - midLineInteractWidth) / 2.0, y: -midLineInteractHeight / 2.0 - lineMargin, width: midLineInteractWidth, height: midLineInteractHeight)
            bottomMidLine.frame = CGRect.init(x: (cropAreaView.wkWidth - midLineInteractWidth) / 2.0, y: cropAreaView.wkHeight - midLineInteractHeight / 2.0 + lineMargin, width: midLineInteractWidth, height: midLineInteractHeight)
            leftMidLine.frame = CGRect.init(x: -midLineInteractWidth / 2.0 - lineMargin, y:(cropAreaView.wkHeight - midLineInteractHeight) / 2.0, width: midLineInteractWidth, height: midLineInteractHeight)
            rightMidLine.frame = CGRect.init(x: cropAreaView.wkWidth - midLineInteractWidth / 2.0 + lineMargin, y: (cropAreaView.wkHeight - midLineInteractHeight) / 2.0, width: midLineInteractWidth, height: midLineInteractHeight)
        }
        
        

    }
    
    func resetCropAreaByAspectRatio() {
        if imageAspectRatio == 0 {return}
            
        let tmpCornerMargin = self.cornerMargin * (cornerBorderInImage ? 1 : 0)
        var width:CGFloat = 0.0
        var height:CGFloat = 0
        
        if cropAspectRatio == 0 {
            width = (imageView.wkWidth - 2 * tmpCornerMargin) * initialScaleFactor
            height = (imageView.wkHeight - 2 * tmpCornerMargin) * initialScaleFactor
            if showMidLines {
                self.createMidLines()
                self.resetMidLines()
            }
        }
        else
        {
            self.removeMidLines()
            if imageAspectRatio > cropAspectRatio {
                height = (imageView.wkHeight - 2 * tmpCornerMargin) * initialScaleFactor
                width = height * cropAspectRatio
            }
            else
            {
                width = (imageView.wkWidth - 2 * tmpCornerMargin) * initialScaleFactor
                height = width / cropAspectRatio
            }
        }
        
        cropAreaView.frame = CGRect.init(x: (imageView.wkWidth - width) / 2.0, y: (imageView.wkHeight - height) / 2.0, width: width, height: height)
        self.resetCornersOnCropAreaFrameChanged()
        self.resetCropTransparentArea()
        self.resetMinSpaceIfNeeded()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if object is CropAreaView{
            
            if keyPath != "center" {
                let cav = object as! CropAreaView
                cav.resetAllLayer()//内部边框处理  如果在类中覆写了frame和bounds则 此处监听失效，所以只能放到这里来调整
            }
            
            if showMidLines {
                self.resetMidLines()
            }
            self.resetCropTransparentArea()

            
            return
        }
        if object is UIImageView {
            self.resetCropAreaByAspectRatio()
        }
    }
    
    func currentCroppedImage() -> UIImage {
        let scaleFactor = imageView.wkWidth / toCropImage!.size.width
        return toCropImage!.imageAtRect(rect: CGRect.init(x: (cropAreaView.wkLeft - cropAreaBorderLineWidth) / scaleFactor, y: (cropAreaView.wkTop - cropAreaBorderLineWidth) / scaleFactor, width: (cropAreaView.wkWidth - 2 *  cropAreaBorderLineWidth) / scaleFactor, height: (cropAreaView.wkHeight - 2 *  cropAreaBorderLineWidth) / scaleFactor))
    }
    
    
    deinit {

        imageView.removeObserver(self, forKeyPath: "frame")
        cropAreaView.removeObserver(self, forKeyPath: "frame")
        cropAreaView.removeObserver(self, forKeyPath: "center")
        cropAreaView.removeObserver(self, forKeyPath: "bounds")
    }
}
