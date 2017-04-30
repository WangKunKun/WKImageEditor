//
//  MidLineView.swift
//  WKImageEditor
//
//  Created by 天下宅 on 2017/4/6.
//  Copyright © 2017年 天下宅. All rights reserved.
//

import UIKit

class MidLineView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var lineLayer = CAShapeLayer()
    var lineWidth:CGFloat = 0.5
    {
        didSet{self.drawMidLine()}
    }
    var lineHeight:CGFloat = 0.5
    {
        didSet{
            lineLayer.lineWidth = lineHeight
        }
    }
    var lineColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    {
        didSet{self.lineLayer.strokeColor = lineColor.cgColor}
    }
    var type = WKMidLineType.top
    {
        didSet{self.drawMidLine()}
    }
    
    init(lineW: CGFloat,lineH:CGFloat,lineC:UIColor) {
        lineWidth = lineW
        lineHeight = lineH
        lineColor = lineC
        super.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawMidLine() {
        if lineLayer.superlayer != nil {
            lineLayer.removeFromSuperlayer()
        }
        
        lineLayer = CAShapeLayer()
        lineLayer.strokeColor = lineColor.cgColor
        lineLayer.lineWidth = lineHeight
        lineLayer.fillColor = UIColor.clear.cgColor
        
        let midLinePath = UIBezierPath()
        switch type {
        case .top:
            fallthrough
        case .bottom:
            midLinePath.move(to: CGPoint.init(x: (self.wkWidth - lineWidth) / 2.0, y: self.wkHeight / 2.0))
            midLinePath.addLine(to: CGPoint.init(x: (self.wkWidth + lineWidth) / 2.0, y: self.wkHeight / 2.0))
        case .left:
        fallthrough
        case .right:
            midLinePath.move(to: CGPoint.init(x: self.wkWidth / 2.0, y: (self.wkHeight - lineWidth) / 2.0))
            midLinePath.addLine(to: CGPoint.init(x: self.wkWidth / 2.0, y: (self.wkHeight + lineWidth) / 2.0))
        }
        lineLayer.path = midLinePath.cgPath
        self.layer.addSublayer(lineLayer)
        
    }

}
