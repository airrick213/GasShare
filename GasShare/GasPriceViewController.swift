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
import Foundation

class GasPriceViewController: UIViewController {
    
    @IBOutlet weak var gasPriceTextField: InputTextField!
    @IBOutlet weak var gasPriceLabel: UILabel!
    @IBOutlet weak var regularGasButton: UIButton!
    @IBOutlet weak var plusGasButton: UIButton!
    @IBOutlet weak var premiumGasButton: UIButton!
    
    var gasMileage: Double!
    var selectedCoordinate = CLLocationCoordinate2D()
    var selectedLocation = ""
    var zipcode = ""
    var regPrice: Double = 0
    var plusPrice: Double = 0
    var prePrice: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gasPriceTextField.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: "didTapView")
        self.view.addGestureRecognizer(tapRecognizer)
        
        regularGasButton.hidden = true
        plusGasButton.hidden = true
        premiumGasButton.hidden = true
    }
    
    func didTapView() {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func regularGasButtonTapped(sender: AnyObject) {
        reloadLabel(regPrice)
        
        regularGasButton.selected = true
        plusGasButton.selected = false
        premiumGasButton.selected = false
    }
    
    @IBAction func plusGasButtonTapped(sender: AnyObject) {
        reloadLabel(plusPrice)
        
        regularGasButton.selected = false
        plusGasButton.selected = true
        premiumGasButton.selected = false
    }
    
    @IBAction func premiumGasButtonTapped(sender: AnyObject) {
        reloadLabel(prePrice)
        
        regularGasButton.selected = false
        plusGasButton.selected = false
        premiumGasButton.selected = true
    }
    
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        if let identifier = segue.identifier {
            if identifier == "Done" {
                let source = segue.sourceViewController as! MapSearchViewController
                self.selectedCoordinate = source.selectedCoordinate
                self.selectedLocation = source.selectedLocation
                
                if selectedLocation == "" {
                    gasPriceLabel.text = "You haven't selected a location yet"
                    gasPriceTextField.enabled = true
                    
                    deactivateButtons()
                }
                
                else {
                    searchForZipcode()
                }
            }
        }
    }
    
    func deactivateButtons() {
        regularGasButton.selected = false
        plusGasButton.selected = false
        premiumGasButton.selected = false
        
        regularGasButton.hidden = true
        plusGasButton.hidden = true
        premiumGasButton.hidden = true
    }
    
    func searchForZipcode() {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let locationArray = selectedLocation.componentsSeparatedByString(", ")
        if locationArray.count < 2 {
            UIAlertView(title: "Sorry", message: "Could not find city or state, please select a different location", delegate: nil, cancelButtonTitle: "OK").show()
            return
        }
        
        let apiKey = "AFxjkQ3OQOUhs8uSZu3jAGEOeqMieViOAP8VFcKw0FOtNimNMp7n6LbkcYCrTVfu"
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
                self.gasPriceLabel.text = "\(self.selectedLocation): Gas price could not be found"
                
                self.deactivateButtons()
            }
        }
    }
    
    func handleFindGasPriceResponse(data: AnyObject) {
        let html = data as! String
        
        var error: NSError?
        var parser = HTMLParser(html: html, error: &error)
        
        if error != nil {
            UIAlertView(title: "Sorry", message: "Network request failed, check your connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
            
            self.gasPriceLabel.text = "\(self.selectedLocation): Gas price could not be found"
            deactivateButtons()
        }
        
        var bodyNode = parser.body
        
        var regPrices = [Double]()
        var plusPrices = [Double]()
        var prePrices = [Double]()
        
        var count = 0
        var numCells = 0
        
        if let priceNodes = bodyNode?.findChildTags("td") {
            for node in priceNodes {
                let contents = node.contents
                
                if !contents.isEmpty {
                    if numCells > 10 {
                        if contents[contents.startIndex] == "$" {
                            let startIndex = advance(contents.startIndex, 1)
                            let endIndex = advance(contents.startIndex, 6)
                            let doubleValue = NSString(string: contents.substringWithRange(Range<String.Index>(start: startIndex, end: endIndex))).doubleValue
                            
                            if doubleValue > 0 {
                                if count == 0 {
                                    regPrices.append(doubleValue)
                                }
                                else if count == 1 {
                                    plusPrices.append(doubleValue)
                                }
                                else if count == 2 {
                                    prePrices.append(doubleValue)
                                }
                            }
                            
                            count = (count + 1) % 4
                        }
                        
                        else if contents == "N/A" {
                            count = (count + 1) % 4
                        }
                    }
                    
                    numCells++
                    if numCells == 70 {
                        break
                    }
                }
            }
        }
        
        
        regPrice = average(regPrices)
        plusPrice = average(plusPrices)
        prePrice = average(prePrices)
        
        gasPriceTextField.enabled = false
        reloadLabel(regPrice)
        regularGasButton.selected = true
        plusGasButton.selected = false
        premiumGasButton.selected = false
        
        regularGasButton.hidden = false
        plusGasButton.hidden = false
        premiumGasButton.hidden = false
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
    
    func reloadLabel(price: Double) {
        if price == 0 {
            gasPriceLabel.text = "\(selectedLocation): Gas price could not be found"
        }
        else {
            let priceString = NSString(format: "\(selectedLocation): $%.2f", price)
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
                let labelText = gasPriceLabel.text!
                let strIndex = advance(labelText.startIndex, count(labelText) - 4)
                routeSearchViewController.gasPrice = NSString(string: labelText.substringFromIndex(strIndex)).doubleValue
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
