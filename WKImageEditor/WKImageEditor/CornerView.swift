//
//  CornerView.swift
//  WKImageEditor
//
//  Created by 天下宅 on 2017/3/31.
//  Copyright © 2017年 天下宅. All rights reserved.
//

import UIKit

class CornerView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var lineWidth:CGFloat {
        didSet{
            self.cornerShapeLayer.strokeColor = lineColor.cgColor
        }
    }
    var lineColor:UIColor {
        didSet{
            self.drawCornerLines()
        }
    }
    
    var cornerPosition:WKCropAreaCornerPosition = .topLeft
    {
        didSet{
            self.drawCornerLines()
        }
    }
    
    var relativeViewX:CornerView?
    var relativeViewY:CornerView?
    var cornerShapeLayer:CAShapeLayer = CAShapeLayer()
    
    init(frame: CGRect, lineC:UIColor,lineW:CGFloat) {
        self.lineColor = lineC
        self.lineWidth = lineW
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawCornerLines()  {
        if (cornerShapeLayer.superlayer != nil)
        {
            cornerShapeLayer.removeFromSuperlayer()
        }
        
        cornerShapeLayer.lineWidth = lineWidth
        cornerShapeLayer.strokeColor = lineColor.cgColor
        cornerShapeLayer.fillColor = UIColor.clear.cgColor
        
        let path = UIBezierPath()
        let paddingX = lineWidth / 2.0
        let paddingY = lineWidth / 2.0
        switch cornerPosition {
        case .topLeft:
            path.move(to: CGPoint.init(x: self.wkWidth, y: paddingY))
            path.addLine(to: CGPoint.init(x: paddingX, y: paddingY))
            path.addLine(to: CGPoint.init(x: paddingX, y: self.wkHeight))
        case .topRight:
            path.move(to: CGPoint.init(x: 0, y: paddingY))
            path.addLine(to: CGPoint.init(x:self.wkWidth - paddingX, y: paddingY))
            path.addLine(to: CGPoint.init(x: self.wkWidth - paddingX, y: self.wkHeight))
        case .bottomLeft:
            path.move(to: CGPoint.init(x: paddingY, y: 0))
            path.addLine(to: CGPoint.init(x: paddingX, y: self.wkHeight - paddingY))
            path.addLine(to: CGPoint.init(x: self.wkWidth, y: self.wkHeight - paddingY))
        case .bottomRight:
            path.move(to: CGPoint.init(x: self.wkWidth - paddingX, y: 0))
            path.addLine(to: CGPoint.init(x: self.wkWidth - paddingX, y: self.wkHeight - paddingY))
            path.addLine(to: CGPoint.init(x: 0, y: self.wkHeight - paddingY))
        }
        
        cornerShapeLayer.path = path.cgPath
        self.layer.addSublayer(cornerShapeLayer)
        
    }
    
    func updateSizeWithWidth(width:CGFloat, height:CGFloat)  {
        switch self.cornerPosition {
        case .topLeft:
            self.frame = CGRect.init(x: self.wkTop, y: self.wkLeft, width: width, height: height)
        case .topRight:
            self.frame = CGRect.init(x: self.wkRight - width, y: self.wkLeft, width: width, height: height)
        case .bottomLeft:
            self.frame = CGRect.init(x: self.wkTop, y: self.wkBottom - height, width: width, height: height)
        case .bottomRight:
            self.frame = CGRect.init(x: self.wkRight - width, y: self.wkBottom - height, width: width, height: height)
        }
        self.drawCornerLines()
    }
    
}
