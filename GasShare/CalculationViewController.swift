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
    @IBOutlet weak var toolbarHeight: NSLayoutConstraint!
    
    var gasMileage: Double!
    var gasPrice: Double!
    var routeDistance: Double!
    var totalPrice: Double!
    var individualCost: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbarHeight.constant = self.view.frame.height * 0.16
        
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
    
}
