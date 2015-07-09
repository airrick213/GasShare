//
//  GasPriceViewController.swift
//  GasShare
//
//  Created by Eric Kim on 7/6/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class GasPriceViewController: UIViewController {
    
    @IBOutlet weak var gasStationLocationLabel: UILabel!
    var gasMileage: Int!
    var selectedCoordinate = CLLocationCoordinate2D()
    var selectedLocation = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        if let identifier = segue.identifier {
            if identifier == "Cancel" {
                gasStationLocationLabel.text = "You haven't entered a location yet"
            }
            else if identifier == "Done" {
                let source = segue.sourceViewController as! MapSearchViewController
                self.selectedCoordinate = source.mapViewController.selectedCoordinate
                self.selectedLocation = source.mapViewController.selectedLocation
                
                if selectedLocation == "" {
                    gasStationLocationLabel.text = "You haven't selected a location yet"
                }
                
                else {
                    gasStationLocationLabel.text = selectedLocation + ": " //+ price
                }
            }
        }
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
