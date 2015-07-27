//
//  CalculationViewController.swift
//  GasShare
//
//  Created by Eric Kim on 7/10/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit

class CalculationViewController: UIViewController {

    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var numberOfPassengersLabel: UILabel!
    @IBOutlet weak var individualCostLabel: UILabel!
    
    var gasMileage: Double!
    var gasPrice: Double!
    var routeDistance: Double!
    var totalPrice: Double!
    var individualCost: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
