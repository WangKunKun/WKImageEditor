//
//  WKPopView.swift
//  WKImageEditor
//
//  Created by apple on 17/4/30.
//  Copyright © 2017年 天下宅. All rights reserved.
//

import UIKit


class WKPopView: UIView {
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
    private var contentView:UIView
    private var bgView:UIView
    
    //contentView的高度
    private var thisHeight:CGFloat = 0
    
    private var IV:UIImageView = UIImageView()
    var image:UIImage?
    {
        get{
            return IV.image
        }
        
        set{
            IV.image = newValue
        }
    }
    
    
    
    init() {
        contentView = UIView()
        contentView.backgroundColor = UIColor.white
        bgView = UIView.init(frame:CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        super.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        
        self.addSubview(bgView)
        
        contentView.layer.cornerRadius = 5
        contentView.layer.shadowOpacity = 0.8
        contentView.layer.shadowColor = UIColor.gray.cgColor
        contentView.layer.shadowOffset = CGSize.init(width:1, height:1)
        self.addSubview(contentView)
        
        
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tap(tap:)))
        bgView.addGestureRecognizer(tap)
        
        contentView.layer.cornerRadius = 5
        contentView.layer.shadowOpacity = 0.8
        contentView.layer.shadowColor = UIColor.gray.cgColor
        contentView.layer.shadowOffset = CGSize.init(width:1, height:1)
    
        IV.frame = CGRect.init(x: 0, y: 0, width: 280, height: 280)
        IV.contentMode = .scaleAspectFit
        contentView.addSubview(IV)
        thisHeight = 280
        
        self.finishLayout()
        
        self.alpha = 0
        
    }
    
    func tap(tap:UITapGestureRecognizer) {
        self.show(flag:false)
    }
    
    
    func finishLayout() {
        
        
        weak var weakSelf = self
        
        self.addSubview(contentView)
        contentView.wkHeight = thisHeight
        contentView.wkWidth = 280
        contentView.center = weakSelf!.center


    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(flag:Bool,view:UIView? = nil){
        
        if flag {
            var thisView = UIApplication.shared.keyWindow! as UIView
            
            if view != nil
            {
                thisView = view!
            }
            
            thisView.addSubview(self)
            
        }
        
        let alpha:CGFloat = flag ? 1 : 0
        
        UIView.animate(withDuration: 0.26, animations: {
            self.alpha = alpha
            self.layoutIfNeeded()
        }) { (finished) in
            if finished{
                if !flag{
                    self.removeFromSuperview()
                }
            }
        }
    }
    
    
}


