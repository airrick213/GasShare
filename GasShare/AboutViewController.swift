//
//  AboutViewController.swift
//  GasShare
//
//  Created by Eric Kim on 7/27/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.scrollRangeToVisible(NSRange(0...1))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
