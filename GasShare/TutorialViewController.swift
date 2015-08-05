//
//  TutorialViewController.swift
//  GasShare
//
//  Created by Eric Kim on 8/5/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var pageIndex: Int!
    var descriptionText: String!
    var imageFile: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionLabel.text = descriptionText
        imageView.image = UIImage(named: imageFile)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
