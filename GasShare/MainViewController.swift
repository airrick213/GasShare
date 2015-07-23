//
//  MainViewController.swift
//  GasShare
//
//  Created by Eric Kim on 7/23/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var mainToolbar: MainToolbar!
    @IBOutlet weak var gasMileageToolbar: GasMileageToolbar!
    @IBOutlet weak var gasPriceToolbar: GasPriceToolbar!
    @IBOutlet weak var mainToolbarHeight: NSLayoutConstraint!
    @IBOutlet weak var gasMileageToolbarHeight: NSLayoutConstraint!
    @IBOutlet weak var gasPriceToolbarHeight: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIButton!
    
    var screenHeight: CGFloat!
    
    @IBAction func gasMileageButtonPressed(sender: AnyObject) {
        animateOut(mainToolbar, andShow: gasMileageToolbar)
    }

    
    @IBAction func gasPriceButtonPressed(sender: AnyObject) {
        animateOut(mainToolbar, andShow: gasPriceToolbar)
    }
    
    @IBAction func gasMileageDoneButtonPressed(sender: AnyObject) {
        animateOut(gasMileageToolbar, andShow: mainToolbar)
    }
    
    @IBAction func gasPriceDoneButtonPressed(sender: AnyObject) {
        animateOut(gasPriceToolbar, andShow: mainToolbar)
    }
    
    func animateOut(firstView: UIView, andShow secondView: UIView) {
        secondView.frame.origin.y = screenHeight
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            firstView.frame.origin.y = self.screenHeight
            
            self.view.layoutIfNeeded()
            }) { (response: Bool) -> Void in
                firstView.hidden = true
                secondView.hidden = false
                
                UIView.animateWithDuration(0.25) {
                    secondView.frame.origin.y = self.screenHeight - secondView.frame.height
                    
                    self.view.layoutIfNeeded()
                }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.hidden = true
        
        screenHeight = self.view.frame.height
        
        mainToolbarHeight.constant = screenHeight * 0.16
        gasMileageToolbarHeight.constant = screenHeight * 0.25
        gasPriceToolbarHeight.constant = screenHeight * 0.33
        
        gasMileageToolbar.hidden = true
        gasPriceToolbar.hidden = true
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
