//
//  CarPickerViewController.swift
//  GasShare
//
//  Created by Eric Kim on 7/30/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit
import Kanna
import MBProgressHUD

class CarPickerViewController: UIViewController {
    
    @IBOutlet weak var gasMileageLabel: UILabel!
    @IBOutlet weak var carPickerView: UIPickerView!
    
    var years: [String] = []
    var makes: [String] = []
    var models: [String] = []
    
    var year: String!
    var make: String!
    var model: String!
    var carID: String!
    var gasMileageText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AlamofireHelper.scrapeHTMLForURL("http://www.fueleconomy.gov/ws/rest/vehicle/menu/year", responseHandler: handleLoadYearsResponse, view: self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleLoadYearsResponse(data: AnyObject) {
        KannaHelper.ParseXMLFromData(data, view: self.view) { (doc: XMLDocument) -> Void in
            self.years = []
            
            for node in doc.css("value") {
                self.years.append(node.text!)
            }
            
            self.carPickerView.reloadComponent(0)
        }
    }
    
    func handleLoadMakesResponse(data: AnyObject) {
        KannaHelper.ParseXMLFromData(data, view: self.view) { (doc: XMLDocument) -> Void in
            self.makes = []
            
            for node in doc.css("value") {
                self.makes.append(node.text!)
            }
            
            self.carPickerView.reloadComponent(1)
        }
    }
    
    func handleLoadModelsResponse(data: AnyObject) {
        KannaHelper.ParseXMLFromData(data, view: self.view) { (doc: XMLDocument) -> Void in
            self.models = []
            
            for node in doc.css("value") {
                self.models.append(node.text!)
            }
            
            self.carPickerView.reloadComponent(2)
        }
    }
    
    func handleLoadIDResponse(data: AnyObject) {
        KannaHelper.ParseXMLFromData(data, view: self.view) { (doc: XMLDocument) -> Void in
            if let node = doc.at_css("value") {
                self.carID = node.text!
                
                AlamofireHelper.scrapeHTMLForURL("http://www.fueleconomy.gov/ws/rest/vehicle/\(self.carID)", responseHandler: self.handleLoadGasMileageResponse, view: self.view)
            }
        }
    }
    
    func handleLoadGasMileageResponse(data: AnyObject) {
        KannaHelper.ParseXMLFromData(data, view: self.view) { (doc: XMLDocument) -> Void in
            if let node = doc.at_css("comb08") {
                self.gasMileageText = NSString(format: "%.1f", NSString(string: node.text!).doubleValue) as String
                
                self.gasMileageLabel.text = "\(self.gasMileageText) mi/gal"
            }
            
            else {
                UIAlertView(title: "Sorry", message: "Could not find gas mileage, please try a different car", delegate: nil, cancelButtonTitle: "OK").show()
                self.gasMileageLabel.text = "Gas Mileage?"
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "CarPickerDone" {
            if gasMileageLabel.text == "Gas Mileage?" {
                UIAlertView(title: "No Car Selected", message: "Please select your car model", delegate: nil, cancelButtonTitle: "OK").show()
                self.gasMileageLabel.text = "Gas Mileage?"
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                return false
            }
            return true
        }
        return true
    }
    
}

extension CarPickerViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return years.count
        }
        else if component == 1 {
            return makes.count
        }
        else {
            return models.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var label = UILabel()
        
        if component == 0 {
            label.text = years[row]
        }
        else if component == 1 {
            label.text = makes[row]
        }
        else {
            label.text = models[row]
        }
        
        label.font = UIFont(name: "Avenir", size: 24)
        label.textColor = UIColor.whiteColor()
        
        return label
    }
    
}

extension CarPickerViewController: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            year = years[row]
            
            AlamofireHelper.scrapeHTMLForURL("http://www.fueleconomy.gov/ws/rest/vehicle/menu/make?year=\(year)", responseHandler: handleLoadMakesResponse, view: self.view)
        }
        else if component == 1 {
            make = NSString(string: makes[row]).stringByReplacingOccurrencesOfString(" ", withString: "%20") as String
            
            AlamofireHelper.scrapeHTMLForURL("http://www.fueleconomy.gov/ws/rest/vehicle/menu/model?year=\(year)&make=\(make)", responseHandler: handleLoadModelsResponse, view: self.view)
        }
        else {
            model = NSString(string: models[row]).stringByReplacingOccurrencesOfString(" ", withString: "%20") as String
            
            AlamofireHelper.scrapeHTMLForURL("http://www.fueleconomy.gov/ws/rest/vehicle/menu/options?year=\(year)&make=\(make)&model=\(model)", responseHandler: handleLoadIDResponse, view: self.view)
        }
    }
    
}
