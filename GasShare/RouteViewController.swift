//
//  RouteViewController.swift
//  GasShare
//
//  Created by Eric Kim on 7/7/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit

class RouteViewController: UIViewController {
    
    @IBOutlet weak var routeDistanceTextField: UITextField!
    var gasMileage: Int!
    var gasPrice: Double!
    var routeDistance: Double!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "RouteDistanceDone" {
            if routeDistanceTextField.text.isEmpty {
                let alert = UIAlertView()
                alert.title = "No Route Distance"
                alert.message = "Please enter the distance of your route"
                alert.addButtonWithTitle("OK")
                alert.show()
                
                return false
            }
            else {
                return true
            }
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RouteDistanceDone" {
            let calculationViewController = segue.destinationViewController as! CalculationViewController
            
            routeDistance = NSString(string: routeDistanceTextField.text).doubleValue
            
            calculationViewController.gasPrice = gasPrice
            calculationViewController.gasMileage = gasMileage
            calculationViewController.routeDistance = routeDistance
        }
    }

}
