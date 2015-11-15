//
//  CalculationViewController.swift
//  GasShare
//
//  Created by Eric Kim on 7/10/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit
import Venmo_iOS_SDK

class CalculationViewController: UIViewController {

    @IBOutlet weak var numberOfPassengersLabel: UILabel!
    @IBOutlet weak var individualCostLabel: UILabel!
    @IBOutlet weak var venmoButton: UIButton!
    
    var gasMileage: Double!
    var gasPrice: Double!
    var routeDistance: Double!
    var totalPrice: Double!
    var individualCost: Double!
    
    @IBAction func venmoButtonTapped(sender: AnyObject) {
        Venmo.sharedInstance().requestPermissions(["make_payments", "access_friends"], withCompletionHandler: { (success: Bool, error: NSError!) -> Void in
            if success {
                self.performSegueWithIdentifier("UseVenmo", sender: self)
            }
            else {
                UIAlertView(title: "Authorization failed", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        venmoButton.titleLabel!.adjustsFontSizeToFitWidth = true
        
        totalPrice = (gasPrice! / gasMileage!) * routeDistance!
        
        updateNumberOfPassengersLabel(1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func numberOfPassengersChanged(sender: UIStepper) {
        updateNumberOfPassengersLabel(sender.value)
    }
    
    
    func updateNumberOfPassengersLabel(numberOfPassengers: Double) {
        numberOfPassengersLabel.text = NSString(format: "Number of Passengers: %.0f", numberOfPassengers) as String
        updateIndividualCost(numberOfPassengers)
    }
    
    func updateIndividualCost(numberOfPassengers: Double) {
        individualCost = totalPrice / numberOfPassengers
        updateIndividualCostLabel()
    }
    
    func updateIndividualCostLabel() {
        individualCostLabel.text = NSString(format: "$%.2f", individualCost) as String
    }

    // MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "UseVenmo" {
            if individualCost < 0.02 {
                UIAlertView(title: "Not Enough Cost", message: "The cost must be at least $0", delegate: nil, cancelButtonTitle: "OK")
                return false
            }
            
            return true
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "UseVenmo" {
                let venmoViewController = segue.destinationViewController as! VenmoViewController
                
                venmoViewController.cost = NSString(string: individualCostLabel.text!.substringFromIndex(individualCostLabel.text!.startIndex.advancedBy(1))).doubleValue
            }
        }
    }
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        
    }
    
}
