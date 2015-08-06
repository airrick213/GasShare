//
//  TutorialRootViewController.swift
//  GasShare
//
//  Created by Eric Kim on 8/5/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit

class TutorialRootViewController: UIViewController {
        
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var pageDescriptions: [String]!
    var pageImages: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.hidden = true
        
        pageDescriptions = [
            "Enter the route's start and end locations",
            "Enter your car's gas mileage",
            "Enter the gas price",
            "See how much everyone has to pay"
        ]
        
        pageImages = [
            "Route",
            "Gas-Mileage",
            "Gas-Price",
            "Calculation"
        ]
        
        
        scrollView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        let scrollViewWidth:CGFloat = scrollView.frame.width
        let scrollViewHeight:CGFloat = scrollView.frame.height
        
        let imageSideDimension = doneButton.frame.origin.y - descriptionLabel.frame.origin.y - descriptionLabel.frame.height
        
        for x in 0 ..< pageImages.count {
            var imageView = UIImageView(frame: CGRectMake((scrollViewWidth * CGFloat(x)) - ((imageSideDimension - self.view.frame.width) / 2), 0, imageSideDimension, imageSideDimension))
            imageView.image = UIImage(named: pageImages[x])
            
            scrollView.addSubview(imageView)
        }
        
        descriptionLabel.text = pageDescriptions[0]
        
        scrollView.contentSize = CGSizeMake(self.view.frame.width * CGFloat(pageImages.count), scrollViewHeight)
        pageControl.currentPage = 0

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "FinishTutorial" {
                let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(true, forKey: "usedAppBefore")
                
                defaults.synchronize()
            }
        }
    }
    
}

extension TutorialRootViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageWidth: CGFloat = CGRectGetWidth(scrollView.frame)
        let currentPage: CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        
        let currentPageIndex = Int(currentPage)
        
        pageControl.currentPage = currentPageIndex
        
        if currentPageIndex == pageDescriptions.count - 1 {
            doneButton.hidden = false
        }
        
        descriptionLabel.text = pageDescriptions[currentPageIndex]
    }
    
}
