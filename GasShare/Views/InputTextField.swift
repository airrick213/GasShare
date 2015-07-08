//
//  InputTextField.swift
//  GasShare
//
//  Created by Eric Kim on 7/6/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit

class InputTextField: UITextField {

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if !self.enabled {
            self.backgroundColor = UIColor(red: 149/225.0, green: 165/225.0, blue: 166/225.0, alpha: 1.0)
        }
        else {
            self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }

}
