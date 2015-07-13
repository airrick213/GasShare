//
//  GasPriceViewController.swift
//  GasShare
//
//  Created by Eric Kim on 7/6/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit
import GoogleMaps
import MBProgressHUD
import SwiftyJSON
import Alamofire
import CoreLocation

class GasPriceViewController: UIViewController {
    
    @IBOutlet weak var gasPriceTextField: InputTextField!
    @IBOutlet weak var gasPriceLabel: UILabel!
    var gasMileage: Int!
    var selectedCoordinate = CLLocationCoordinate2D()
    var selectedLocation = ""
    var gasPrice: Double = 0
    let gasType = "reg"

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        if let identifier = segue.identifier {
            if identifier == "Done" {
                let source = segue.sourceViewController as! MapSearchViewController
                self.selectedCoordinate = source.mapViewController.selectedCoordinate
                self.selectedLocation = source.mapViewController.selectedLocation
                
                if selectedLocation == "" {
                    gasPriceLabel.text = "You haven't selected a location yet"
                }
                
                else {
                    findGasPrices()
                    gasPriceTextField.enabled = false
                }
            }
        }
    }
    
    func findGasPrices() {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let apiKey = "rfej9napna"
        
        let paramString1 = "/stations/radius/\(selectedCoordinate.latitude)/\(selectedCoordinate.longitude)"
        let paramString2 = "/5/\(gasType)/distance/\(apiKey).json"
        let requestString = "http://devapi.mygasfeed.com/" + paramString1 + paramString2
        
        
        Alamofire.request(.GET, requestString, parameters: nil).responseJSON(options: .allZeros) { (_, response, data, error) -> Void in
            hud.hide(true)
            
            if self.requestSucceeded(response, error: error) {
                self.handleResponse(data!)
            }
            else {
                UIAlertView(title: "Sorry", message: "Network request failed, check your connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
            }
        }
    }
    
    func requestSucceeded(response: NSURLResponse!, error: NSError!) -> Bool {
        if let httpResponse = response as? NSHTTPURLResponse {
            return error == nil && httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
        }
        
        return false
    }
    
    func handleResponse(data: AnyObject) {
        let json = JSON(data)
        
        if let stations = json["stations"].array {
            let prices = stations.map { NSString(string: $0["\(self.gasType)_price"].string!).doubleValue }
            
            gasPrice = average(prices)
        }
        
        reloadLabel()
    }
    
    func average(nums: [Double]) -> Double {
        var sum: Double = 0
        var count: Double = 0
        for num in nums {
            sum += num
            count++
        }
        
        return sum / count
    }
    
    func reloadLabel() {
        if gasPrice == 0 {
            gasPriceLabel.text = "\(selectedLocation): Gas price could not be found"
        }
        else {
            let priceString = NSString(format: "\(selectedLocation): $%.2f", gasPrice)
            gasPriceLabel.text = priceString as String
        }
    }

    // MARK: - Navigation


    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "GasPriceDone" {
            if (gasPriceTextField.text.isEmpty && gasPriceLabel.text == "You haven't selected a location yet") || gasPriceLabel.text!.rangeOfString("could not be found") != nil {
                let alert = UIAlertView()
                alert.title = "No Gas Price"
                alert.message = "Please enter your gas price or select the location of your gas station"
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
        if segue.identifier == "GasPriceDone" {
            let routeViewController = segue.destinationViewController as! RouteViewController
            
            if gasPriceLabel.text == "You haven't selected a location yet" || gasPriceLabel.text!.rangeOfString("could not be found") != nil {
                routeViewController.gasPrice = NSString(string: gasPriceTextField.text!).doubleValue
            }
            else {
                routeViewController.gasPrice = gasPrice
            }
        
            routeViewController.gasMileage = gasMileage
        }
    }

}
