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
    
    @IBOutlet weak var gasStationLocationLabel: UILabel!
    var gasMileage: Int!
    var selectedCoordinate = CLLocationCoordinate2D()
    var selectedLocation = ""
    var regPrice: Double = 0

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
                    gasStationLocationLabel.text = "You haven't selected a location yet"
                }
                
                else {
                    findGasPrices()
                }
            }
        }
    }
    
    func findGasPrices() {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let apiKey = "rfej9napna"
        
        let paramString1 = "/stations/radius/\(selectedCoordinate.latitude)/\(selectedCoordinate.longitude)"
        let paramString2 = "/5/reg/distance/\(apiKey).json"
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
            let regPrices = stations.map { NSString(string: $0["reg_price"].string!).doubleValue }
            
            regPrice = average(regPrices)
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
        if regPrice == 0 {
            gasStationLocationLabel.text = "\(selectedLocation): Gas price could not be found"
        }
        else {
            let priceString = NSString(format: "\(selectedLocation): $%.2f", regPrice)
            gasStationLocationLabel.text = priceString as String
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
