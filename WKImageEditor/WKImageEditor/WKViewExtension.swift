//
//  WKViewExtension.swift
//  商家端Swift
//
//  Created by 天下宅 on 16/8/17.
//  Copyright © 2016年 天下宅. All rights reserved.
//

import Foundation
import UIKit


//view frame属性快速获取
extension UIView
{
    var wkLeft:CGFloat{
        set{
            self.frame.origin.x = newValue
        }
        get{
            return self.frame.origin.x
        }
    }
    
    var wkTop:CGFloat{
        set{
            self.frame.origin.y = newValue
        }
        get{
            return self.frame.origin.y
        }
    }
    
    var wkRight:CGFloat{
        
        get{
            return self.frame.maxX
        }
    }
    
    var wkBottom:CGFloat{
        get{
            return self.frame.maxY
        }
    }
    
    var wkMidX:CGFloat{
        get{ return self.frame.midX }
    }
    
    var wkMidY:CGFloat{
        get{ return self.frame.midY }
    }
    
    var wkWidth:CGFloat{
        set{
            let frame = CGRect.init(x: self.wkLeft, y: self.wkTop, width: newValue, height: self.frame.height)
            self.frame = frame
        }
        
        get{
            return self.frame.width
        }
    }
    
    
    var wkHeight:CGFloat{
        set{
            let frame = CGRect.init(x: self.wkLeft, y: self.wkTop, width: self.frame.width, height: newValue)
            self.frame = frame
        }
        get{
            return self.frame.height
        }
    }
    
    var wkOrigin:CGPoint{
        set{
            self.frame.origin = newValue
        }
        
        get{
            return self.frame.origin
        }
    }
    
    var wkSize:CGSize{
        set{
            self.frame.size = newValue
        }
        
        get{
            return self.frame.size
        }
    }
    
    
}

//自带 关闭编辑模式属性
extension UIView
{
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.endEditing(true)
    }
    
}
