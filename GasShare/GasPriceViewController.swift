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
                //set label text to location
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
