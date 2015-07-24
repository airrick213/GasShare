//
//  Toolbar.swift
//  GasShare
//
//  Created by Eric Kim on 7/23/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit

class CustomToolbar: UIView {

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        self.backgroundColor = UIColor.blueColor()
        
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        
        gradient.colors = [UIColor.whiteColor(), UIColor(hue: 359.0/360.0, saturation: 0, brightness: 0.85, alpha: 1.0)]
        
        let sublayerCount: UInt32 = UInt32(self.layer.sublayers!.count + 1)
        //self.layer.insertSublayer(gradient, atIndex: sublayerCount)
    }

}
