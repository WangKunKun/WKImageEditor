//
//  ViewController.swift
//  WKImageEditor
//
//  Created by 天下宅 on 2017/3/31.
//  Copyright © 2017年 天下宅. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var resultIV: UIImageView!
    @IBOutlet var imageView: WKImageView!
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

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clip(_ sender: UIButton) {
        
        resultIV.image = imageView.currentCroppedImage()
    }

}

