//
//  RouteViewController.swift
//  GasShare
//
//  Created by Eric Kim on 7/7/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import MBProgressHUD
import SwiftyJSON
import Alamofire

class RouteViewController: UIViewController {
    
    @IBOutlet weak var startLocationButton: UIButton!
    @IBOutlet weak var endLocationButton: UIButton!
    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var endLocationLabel: UILabel!
    @IBOutlet weak var routeDistanceLabel: UILabel!
    var gasMileage: Int!
    var gasPrice: Double!
    var routeDistance: Double!
    var startCoordinate = CLLocationCoordinate2D()
    var startLocation = "No start location selected"
    var endCoordinate = CLLocationCoordinate2D()
    var endLocation = "No end location selected"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLocationButton.selected = false
        endLocationButton.selected = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startLocationButtonTapped(sender: AnyObject) {
        startLocationButton.selected = true
    }
    
    @IBAction func endLocationButtonTapped(sender: AnyObject) {
        endLocationButton.selected = true
    }
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        if let identifier = segue.identifier {
            if identifier == "Done" {
                let source = segue.sourceViewController as! RouteSearchViewController
                
                if startLocationButton.selected {
                    self.startCoordinate = source.routeMapViewController.selectedCoordinate
                    self.startLocation = source.routeMapViewController.selectedLocation
                    updateStartLocationLabel()
                    self.startLocationButton.selected = false
                }
                else if endLocationButton.selected {
                    self.endCoordinate = source.routeMapViewController.selectedCoordinate
                    self.endLocation = source.routeMapViewController.selectedLocation
                    updateEndLocationLabel()
                    self.endLocationButton.selected = false
                }
            }
        }
    }
    
    func updateStartLocationLabel() {
        if startLocation == "" {
            startLocationLabel.text = "No start location selected"
        }
        else {
            startLocationLabel.text = startLocation
        }
    }
    
    func updateEndLocationLabel() {
        if endLocation == "" {
            endLocationLabel.text = "No start location selected"
        }
        else {
            endLocationLabel.text = endLocation
        }
    }

    // MARK: - Navigation

    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "RouteDistanceDone" {
            if routeDistanceLabel.text == "You haven't selected the start and end locations yet" {
                let alert = UIAlertView()
                alert.title = "No Route Distance"
                alert.message = "Please enter the start and end locations of your route"
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
            
            //routeDistance = NSString(string: routeDistanceTextField.text).doubleValue
            
            calculationViewController.gasPrice = gasPrice
            calculationViewController.gasMileage = gasMileage
            calculationViewController.routeDistance = routeDistance
        }
    }

}
