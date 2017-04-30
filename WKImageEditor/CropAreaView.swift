//
//  CropAreaView.swift
//  WKImageEditor
//
//  Created by 天下宅 on 2017/4/7.
//  Copyright © 2017年 天下宅. All rights reserved.
//

import UIKit




class CropAreaView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    var crossLineLayer = CAShapeLayer()
    var crossLineWidth:CGFloat = 0.5
    {
        didSet{
            crossLineLayer.lineWidth = crossLineWidth
        }
    }
    var crossLineColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    {
        didSet{
            crossLineLayer.strokeColor = crossLineColor.cgColor
        }
    }
    
    
    var borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    {
        didSet{
            borderLayer.strokeColor = borderColor.cgColor
        }
    }
    var borderWidth:CGFloat = 0.5
        {
        didSet{self.resetBorderLayerPath()}
    }
    var borderLayer = CAShapeLayer()
    var showCrossLines = true
    {
        willSet{
            if showCrossLines && !newValue {
                crossLineLayer.removeFromSuperlayer()
            }
            else if !showCrossLines && newValue
            {
                self.showCrossLineLayer()
            }
        }
    }
    
    
    init() {
        super.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        self.createBorderLayer()
    }
    
//    override var frame: CGRect
//    {
//        didSet{
//            if showCrossLines{
//                self.showCrossLineLayer()
//            }
//            self.resetBorderLayerPath()
//        }
//    }
//    
//    override var bounds: CGRect
//    {
//        didSet{
//            if showCrossLines{
//                self.showCrossLineLayer()
//            }
//            self.resetBorderLayerPath()
//        }
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetAllLayer()  {
        if showCrossLines{
            self.showCrossLineLayer()
        }
        self.resetBorderLayerPath()
    }
    
    func showCrossLineLayer() {
        let path = UIBezierPath()
        path.move(to: CGPoint.init(x: self.wkWidth / 3.0, y: 0))
        path.addLine(to: CGPoint.init(x: self.wkWidth / 3.0, y: self.wkHeight))
        path.move(to: CGPoint.init(x: self.wkWidth / 3.0 * 2.0, y: 0))
        path.addLine(to: CGPoint.init(x: self.wkWidth / 3.0 * 2.0 , y: self.wkHeight))
        path.move(to: CGPoint.init(x: 0, y: self.wkHeight / 3.0))
        path.addLine(to: CGPoint.init(x: self.wkWidth, y: self.wkHeight / 3.0))
        path.move(to: CGPoint.init(x: 0, y: self.wkHeight / 3.0 * 2.0))
        path.addLine(to: CGPoint.init(x: self.wkWidth, y: self.wkHeight / 3.0 * 2.0))
        
        self.layer.addSublayer(crossLineLayer)
        crossLineLayer.lineWidth = crossLineWidth
        crossLineLayer.strokeColor = crossLineColor.cgColor
        crossLineLayer.path = path.cgPath
    }
    
    func createBorderLayer()  {
        if borderLayer.superlayer != nil {
            borderLayer.removeFromSuperlayer()
        }
        self.layer.addSublayer(borderLayer)
    }
    
    func resetBorderLayerPath()  {
        let path = UIBezierPath.init(rect: CGRect.init(x: borderWidth / 2.0, y: borderWidth / 2.0, width: self.wkWidth - borderWidth, height: self.wkHeight - borderWidth))
        borderLayer.lineWidth = borderWidth
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.path = path.cgPath
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for view in self.subviews {
            if view.frame.contains(point) {
                return view
            }
        }
        
        if self.bounds.contains(point) {
            return self;
        }
        return nil
    }
    
    
    
}
