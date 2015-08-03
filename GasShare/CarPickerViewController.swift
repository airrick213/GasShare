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
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gasMileageLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
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
        
        searchBar.showsScopeBar = false
        tableView.hidden = true
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
            
            self.tableView.reloadData()
        }
    }
    
    func handleLoadMakesResponse(data: AnyObject) {
        KannaHelper.ParseXMLFromData(data, view: self.view) { (doc: XMLDocument) -> Void in
            self.makes = []
            
            for node in doc.css("value") {
                self.makes.append(node.text!)
            }
            
            self.tableView.reloadData()
        }
    }
    
    func handleLoadModelsResponse(data: AnyObject) {
        KannaHelper.ParseXMLFromData(data, view: self.view) { (doc: XMLDocument) -> Void in
            self.models = []
            
            for node in doc.css("value") {
                self.models.append(node.text!)
            }
            
            self.tableView.reloadData()
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

extension CarPickerViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        tableView.hidden = false
        searchBar.showsScopeBar = true
        
        if searchBar.selectedScopeButtonIndex == 0 {
            searchBar.keyboardType = UIKeyboardType.NumberPad
        }
        else {
            searchBar.keyboardType = UIKeyboardType.ASCIICapable
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        tableView.hidden = true
        searchBar.showsScopeBar = false
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if (selectedScope == 1 || selectedScope == 2) && yearLabel.text == "Year?" {
            UIAlertView(title: "No Year Selected", message: "Please select the year of your car model", delegate: nil, cancelButtonTitle: "OK").show()
            
            searchBar.selectedScopeButtonIndex = 0
        }
        else if selectedScope == 2 && makeLabel.text == "Make?" {
            UIAlertView(title: "No Make Selected", message: "Please select the make of your car model", delegate: nil, cancelButtonTitle: "OK").show()
            
            searchBar.selectedScopeButtonIndex = 1
        }
        else {
            tableView.reloadData()
            
            searchBar.resignFirstResponder()
            searchBar.becomeFirstResponder()
        }
    }
    
}

extension CarPickerViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.selectedScopeButtonIndex == 0 {
            return years.count
        }
        else if searchBar.selectedScopeButtonIndex == 1 {
            return makes.count
        }
        else {
            return models.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CarCell", forIndexPath: indexPath) as! CarPickerTableViewCell
        
        if searchBar.selectedScopeButtonIndex == 0 {
            cell.carLabel.text = years[indexPath.row]
        }
        else if searchBar.selectedScopeButtonIndex == 1 {
            cell.carLabel.text = makes[indexPath.row]
        }
        else {
            cell.carLabel.text = models[indexPath.row]
        }
                
        return cell
    }
    
}

extension CarPickerViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchBar.selectedScopeButtonIndex == 0 {
            year = years[indexPath.row]
            
            yearLabel.text = year
            makeLabel.text = "Make?"
            modelLabel.text = "Model?"
            gasMileageLabel.text = "Gas Mileage?"
            
            searchBar.text = ""
            searchBar.selectedScopeButtonIndex = 1
            
            AlamofireHelper.scrapeHTMLForURL("http://www.fueleconomy.gov/ws/rest/vehicle/menu/make?year=\(year)", responseHandler: handleLoadMakesResponse, view: self.view)
            
            searchBar.resignFirstResponder()
            searchBar.becomeFirstResponder()
        }
        else if searchBar.selectedScopeButtonIndex == 1 {
            make = NSString(string: makes[indexPath.row]).stringByReplacingOccurrencesOfString(" ", withString: "%20") as String
            
            makeLabel.text = makes[indexPath.row]
            modelLabel.text = "Model?"
            gasMileageLabel.text = "Gas Mileage?"
            
            searchBar.text = ""
            searchBar.selectedScopeButtonIndex = 2

            AlamofireHelper.scrapeHTMLForURL("http://www.fueleconomy.gov/ws/rest/vehicle/menu/model?year=\(year)&make=\(make)", responseHandler: handleLoadModelsResponse, view: self.view)
            
            searchBar.resignFirstResponder()
            searchBar.becomeFirstResponder()
        }
        else {
            model = NSString(string: models[indexPath.row]).stringByReplacingOccurrencesOfString(" ", withString: "%20") as String
            modelLabel.text = models[indexPath.row]
            
            AlamofireHelper.scrapeHTMLForURL("http://www.fueleconomy.gov/ws/rest/vehicle/menu/options?year=\(year)&make=\(make)&model=\(model)", responseHandler: handleLoadIDResponse, view: self.view)
            
            searchBar.text = ""
            searchBar.showsScopeBar = false
            searchBar.selectedScopeButtonIndex = 0
            searchBar.resignFirstResponder()
            tableView.reloadData()
            tableView.hidden = true
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
}
