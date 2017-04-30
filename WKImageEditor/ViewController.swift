//
//  ViewController.swift
//  WKImageEditor
//
//  Created by 天下宅 on 2017/3/31.
//  Copyright © 2017年 天下宅. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var imageView: WKImageView!
    
    var scrollView = UIScrollView()
    
    var arr:[UIButton] = []
    
    let clipBtn = UIButton.init(type: .system)
    
    var resultView = WKPopView.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        imageView.toCropImage
        imageView.toCropImage = UIImage.init(named: "1.jpeg");
        imageView.showMidLines = true;
        imageView.needScaleCrop = true;
        imageView.showCrossLines = true;
        imageView.cornerBorderInImage = false;
        imageView.cropAreaCornerWidth = 44;
        imageView.cropAreaCornerHeight = 44;
        imageView.minSpace = 30;
        imageView.cropAreaCornerLineColor = .white
        imageView.cropAreaBorderLineColor = .white
        imageView.cropAreaCornerLineWidth = 6;
        imageView.cropAreaBorderLineWidth = 4;
        imageView.cropAreaMidLineWidth = 20;
        imageView.cropAreaMidLineHeight = 6;
        imageView.cropAreaMidLineColor = .white
        imageView.cropAreaCrossLineColor = .white
        imageView.cropAreaCrossLineWidth = 4;
        imageView.initialScaleFactor = 0.8;
        
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.red.cgColor
        
        scrollView.frame = CGRect.init(x: 0, y: 430, width: UIScreen.main.bounds.width, height: 80)
        self.view.addSubview(scrollView)
        scrollView.backgroundColor = UIColor.lightText
        scrollView.contentSize = CGSize.init(width: 80 * 5 , height: 80)
        scrollView.center.x = self.view.center.x
        
        
        for i in 0 ..< 5
        {
            let btn = createBtn(withType: i)
            btn.wkLeft = CGFloat.init(i) * 80.0
            scrollView.addSubview(btn)
            arr.append(btn)
            btn.tag = 100 + i
            btn.addTarget(self, action: #selector(handle(sender:)), for: .touchUpInside)
        }

        clipBtn.wkTop = scrollView.wkBottom + 20
        clipBtn.wkWidth = 150
        clipBtn.wkHeight = 80
        clipBtn.layer.cornerRadius = 4
        clipBtn.layer.borderColor = UIColor.brown.cgColor
        clipBtn.layer.borderWidth = 0.5
        clipBtn.setTitle("裁剪", for: .normal)
        clipBtn.addTarget(self, action: #selector(clip), for: .touchUpInside)
        clipBtn.center.x = self.view.center.x
        self.view.addSubview(clipBtn)
    }
    
    func clip()  {
        resultView.image = imageView.currentCroppedImage()
        resultView.show(flag: true)
    }

    func handle(sender:UIButton) {
        switch sender.tag - 100 {
        case 0:
            imageView.cropAspectRatio = 0
        case 1:
            imageView.cropAspectRatio = 1
        case 2:
            imageView.cropAspectRatio = 3.0 / 4.0
        case 3:
            imageView.cropAspectRatio = 4.0 / 3.0
        case 4:
            imageView.cropAspectRatio = 16.0 / 9.0
        default:
            break
        }
    }
    
    func createBtn(withType type:Int) -> UIButton {
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: 0, y: 0, width: 80, height: 80)
        btn.setTitleColor(.red, for: .normal)
        let layer = CAShapeLayer()
        var title = ""
        var rect = CGRect.zero
        switch type {
        case 0:
            title = "自由"
            rect = CGRect.init(x: 10, y: 10, width: 60, height: 60)
            layer.lineDashPattern = [2,4]
        case 1:
            title = "1:1"
            rect = CGRect.init(x: 10, y: 10, width: 60, height: 60)
        case 2:
            title = "3:4"
            rect = CGRect.init(x: 17.5, y: 10, width: 45, height: 60)

        case 3:
            title = "4:3"
            rect = CGRect.init(x: 10, y: 17.5, width: 60, height: 45)

        case 4:
            title = "16:9"
            rect = CGRect.init(x: 0, y: 10, width: 80, height: 60)
        default:
            break
        }
        
        layer.frame = btn.bounds
        layer.path = UIBezierPath.init(rect: rect).cgPath
        layer.strokeColor = UIColor.gray.cgColor
        layer.lineWidth = 0.5
        layer.fillColor = nil
        btn.layer.addSublayer(layer)
        btn.setTitle(title, for: .normal)
        return btn
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}

