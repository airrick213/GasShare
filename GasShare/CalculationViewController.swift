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

    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var numberOfPassengersLabel: UILabel!
    @IBOutlet weak var individualCostLabel: UILabel!
    @IBOutlet weak var venmoButton: UIButton!
    
    var gasMileage: Double!
    var gasPrice: Double!
    var routeDistance: Double!
    var totalPrice: Double!
    var individualCost: Double!
    
    @IBAction func venmoButtonTapped(sender: AnyObject) {
        Venmo.sharedInstance().requestPermissions(["make_payments"], withCompletionHandler: { (success: Bool, error: NSError!) -> Void in
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
        totalLabel.text! += NSString(format: ": $%.2f", totalPrice) as String
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "UseVenmo" {
                let venmoViewController = segue.destinationViewController as! VenmoViewController
                
                venmoViewController.cost = individualCost
            }
        }
    }
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        
    }
    
}
