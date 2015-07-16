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
    var gasMileage: Double!
    var selectedCoordinate = CLLocationCoordinate2D()
    var selectedLocation = ""
    var zipcode = ""
    var gasPrice: Double = 0
    let gasType = "reg"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gasPriceTextField.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: "didTapView")
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func didTapView() {
        self.view.endEditing(true)
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
                    gasPriceTextField.enabled = true
                }
                
                else {
                    searchForZipcode()
                }
            }
        }
    }
    
    func searchForZipcode() {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let locationArray = selectedLocation.componentsSeparatedByString(", ")
        if locationArray.count < 2 {
            UIAlertView(title: "Sorry", message: "Could not find city or state, please select a different location", delegate: nil, cancelButtonTitle: "OK").show()
            return
        }
        
        let apiKey = "DOEnsVzSQtaFH5HcYyGFINH2GAgo8EYLtC9VyIOocZ4U4L63jMI2Aq5g0lF90DVt"
        let params = "\(apiKey)/city-zips.json/\(locationArray[0])/\(locationArray[1])"
        var requestString = "http://www.zipcodeapi.com/rest/\(params)"
        requestString = requestString.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.allZeros, range: Range<String.Index>(start: requestString.startIndex, end: requestString.endIndex))
        
        Alamofire.request(.GET, requestString, parameters: nil).responseJSON(options: .allZeros) { (_, response, data, error) -> Void in
            hud.hide(true)
            
            if AlamofireHelper.requestSucceeded(response, error: error) {
                self.handleSearchZipcodeResponse(data!)
            }
            else {
                UIAlertView(title: "Sorry", message: "Network request failed, check your connection and try again", delegate: nil, cancelButtonTitle: "OK").show()
            }
        }
    }
    
    func handleSearchZipcodeResponse(data: AnyObject) {
        let json = JSON(data)
        
        if let result = json["zip_codes"].array {
            if let zipcode = result[0].string {
                self.zipcode = zipcode
                findGasPrice()
            }
            else {
                UIAlertView(title: "Sorry", message: "Could not find zipcode, please select a different location", delegate: nil, cancelButtonTitle: "OK").show()
            }
        }
    }
    
    //MARK: Gas Price Code
    
    func findGasPrice() {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let requestString = "http://www.motortrend.com/gas_prices/34/\(zipcode)/"
        
        
        Alamofire.request(.GET, requestString, parameters: nil).responseString { (_, response, data, error) -> Void in
            hud.hide(true)
            
            if AlamofireHelper.requestSucceeded(response, error: error) {
                self.handleFindGasPriceResponse(data!)
            }
            else {
                UIAlertView(title: "Sorry", message: "Network request failed, check your connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
            }
        }
    }
    
    func handleFindGasPriceResponse(data: AnyObject) {
        let json = JSON(data)
        
        if let stations = json["stations"].array {
            let prices = stations.map { NSString(string: $0["\(self.gasType)_price"].string!).doubleValue }
            
            gasPrice = average(prices)
        }
        
        gasPriceTextField.enabled = false
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
            let routeSearchViewController = segue.destinationViewController as! RouteSearchViewController
            
            if gasPriceLabel.text == "You haven't selected a location yet" || gasPriceLabel.text!.rangeOfString("could not be found") != nil {
                routeSearchViewController.gasPrice = NSString(string: gasPriceTextField.text!).doubleValue
            }
            else {
                routeSearchViewController.gasPrice = gasPrice
            }
        
            routeSearchViewController.gasMileage = gasMileage
        }
    }

}

extension GasPriceViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.text.rangeOfString(".") != nil {
            if (string.rangeOfString(".") != nil || count(textField.text.componentsSeparatedByString(".")[1]) + count(string) > 2) {
                return false
            }
        }
        
        return true
    }
    
}
