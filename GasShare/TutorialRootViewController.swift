//
//  TutorialRootViewController.swift
//  GasShare
//
//  Created by Eric Kim on 8/5/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit

class TutorialRootViewController: UIViewController {
    
    var pageViewController: UIPageViewController!
    var pageDescriptions: [String]!
    var pageImages: [String]!
    
    @IBAction func skipButtonTapped(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageDescriptions = [
            "Enter the route start and end locations",
            "Enter your car's gas mileage",
            "Or select your car model",
            "Enter the gas price",
            "Or enter the gas station's location",
            "Hit calculate when you're done!",
            "See how much everyone has to pay"
        ]
        
        pageImages = [
            "Route",
            "Gas-Mileage",
            "Car-Picker",
            "Gas-Price",
            "Gas-Station",
            "Calculate",
            "Calculation"
        ]
        
        pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        pageViewController.dataSource = self
        
        let startingViewController: TutorialViewController = tutorialViewControllerAtIndex(0)!
        let viewControllers = [startingViewController]
        pageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 60)
        
        addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tutorialViewControllerAtIndex(index: Int) -> TutorialViewController? {
        if index < 0 || index >= pageDescriptions.count {
            return nil
        }
        
        let tutorialViewController: TutorialViewController = self.storyboard!.instantiateViewControllerWithIdentifier("TutorialViewController") as! TutorialViewController
        tutorialViewController.imageFile = pageImages[index]
        tutorialViewController.descriptionText = pageDescriptions[index]
        tutorialViewController.pageIndex = index
        
        return tutorialViewController
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

extension TutorialRootViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let tutorialViewController = viewController as! TutorialViewController
        let index = tutorialViewController.pageIndex
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        return tutorialViewControllerAtIndex(index - 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let tutorialViewController = viewController as! TutorialViewController
        let index = tutorialViewController.pageIndex
        
        if index == pageDescriptions.count - 1 || index == NSNotFound {
            return nil
        }
        
        return tutorialViewControllerAtIndex(index + 1)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageDescriptions.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}
