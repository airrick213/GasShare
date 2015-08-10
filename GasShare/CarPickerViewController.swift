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
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    
    var years: [String] = []
    var makes: [String] = []
    var models: [String] = []
    var searchedYears: [String] = []
    var searchedMakes: [String] = []
    var searchedModels: [String] = []
    
    var year: String!
    var make: String!
    var model: String!
    var carID: String!
    var gasMileageText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AlamofireHelper.scrapeHTMLForURL("http://www.fueleconomy.gov/ws/rest/vehicle/menu/year", responseHandler: handleLoadYearsResponse, view: self.view)
        showTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showTableView() {
        searchBar.showsScopeBar = true
        searchBarHeight.constant = 98
        searchBar.becomeFirstResponder()
        tableView.hidden = false
    }
    
    func hideTableView() {
        searchBar.showsScopeBar = false
        searchBarHeight.constant = 44
        searchBar.resignFirstResponder()
        tableView.hidden = true
    }
    
    func handleLoadYearsResponse(data: AnyObject) {
        KannaHelper.ParseXMLFromData(data, view: self.view) { (doc: XMLDocument) -> Void in
            self.years = []
            
            for node in doc.css("value") {
                self.years.append(node.text!)
            }
            
            self.searchedYears = self.years
            
            self.tableView.reloadData()
        }
    }
    
    func handleLoadMakesResponse(data: AnyObject) {
        KannaHelper.ParseXMLFromData(data, view: self.view) { (doc: XMLDocument) -> Void in
            self.makes = []
            
            for node in doc.css("value") {
                self.makes.append(node.text!)
            }
            
            self.searchedMakes = self.makes
            
            self.tableView.reloadData()
        }
    }
    
    func handleLoadModelsResponse(data: AnyObject) {
        KannaHelper.ParseXMLFromData(data, view: self.view) { (doc: XMLDocument) -> Void in
            self.models = []
            
            for node in doc.css("value") {
                self.models.append(node.text!)
            }
            
            self.searchedModels = self.models
            
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
    
    //MARK: Navigation
    
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
        if tableView.hidden {
            showTableView()
        }
        
        searchBar.showsCancelButton = true
        
        if searchBar.selectedScopeButtonIndex == 0 {
            searchBar.keyboardType = UIKeyboardType.NumberPad
        }
        else {
            searchBar.keyboardType = UIKeyboardType.ASCIICapable
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        hideTableView()
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
            
            searchBar.text = ""
            searchBar.resignFirstResponder()
            searchBar.becomeFirstResponder()
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            if searchBar.selectedScopeButtonIndex == 0 {
                searchedYears = years
            }
            else if searchBar.selectedScopeButtonIndex == 1 {
                searchedMakes = makes
            }
            else {
                searchedModels = models
            }
        }
        else {
            if searchBar.selectedScopeButtonIndex == 0 {
                searchedYears = years.filter { $0.rangeOfString(searchText) != nil }
            }
            else if searchBar.selectedScopeButtonIndex == 1 {
                searchedMakes = makes.filter { $0.lowercaseString.rangeOfString(searchText.lowercaseString) != nil }
            }
            else {
                searchedModels = models.filter { $0.lowercaseString.rangeOfString(searchText.lowercaseString) != nil }
            }
        }
        
        tableView.reloadData()
    }
    
}

extension CarPickerViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.selectedScopeButtonIndex == 0 {
            return searchedYears.count
        }
        else if searchBar.selectedScopeButtonIndex == 1 {
            return searchedMakes.count
        }
        else {
            return searchedModels.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CarCell", forIndexPath: indexPath) as! CarPickerTableViewCell
        
        if searchBar.selectedScopeButtonIndex == 0 {
            cell.carLabel.text = searchedYears[indexPath.row]
        }
        else if searchBar.selectedScopeButtonIndex == 1 {
            cell.carLabel.text = searchedMakes[indexPath.row]
        }
        else {
            cell.carLabel.text = searchedModels[indexPath.row]
        }
                
        return cell
    }
    
}

extension CarPickerViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchBar.selectedScopeButtonIndex == 0 {
            year = searchedYears[indexPath.row]
            
            yearLabel.text = year
            makeLabel.text = "Make?"
            modelLabel.text = "Model?"
            gasMileageLabel.text = "Gas Mileage?"
            
            searchBar.scopeButtonTitles = [year, "Make", "Model"] as [AnyObject]?
            
            searchBar.text = ""
            searchBar.selectedScopeButtonIndex = 1
            
            AlamofireHelper.scrapeHTMLForURL("http://www.fueleconomy.gov/ws/rest/vehicle/menu/make?year=\(year)", responseHandler: handleLoadMakesResponse, view: self.view)
            
            searchedYears = years
            searchBar.resignFirstResponder()
            searchBar.becomeFirstResponder()
        }
        else if searchBar.selectedScopeButtonIndex == 1 {
            make = NSString(string: searchedMakes[indexPath.row]).stringByReplacingOccurrencesOfString(" ", withString: "%20") as String
            
            makeLabel.text = searchedMakes[indexPath.row]
            modelLabel.text = "Model?"
            gasMileageLabel.text = "Gas Mileage?"
            
            searchBar.scopeButtonTitles = [year, makeLabel.text!, "Model"] as [AnyObject]?
            
            searchBar.text = ""
            searchBar.selectedScopeButtonIndex = 2

            AlamofireHelper.scrapeHTMLForURL("http://www.fueleconomy.gov/ws/rest/vehicle/menu/model?year=\(year)&make=\(make)", responseHandler: handleLoadModelsResponse, view: self.view)
            
            searchedMakes = makes
            searchBar.resignFirstResponder()
            searchBar.becomeFirstResponder()
        }
        else {
            model = NSString(string: searchedModels[indexPath.row]).stringByReplacingOccurrencesOfString(" ", withString: "%20") as String
            modelLabel.text = searchedModels[indexPath.row]
            
            searchBar.scopeButtonTitles = [year, makeLabel.text!, modelLabel.text!] as [AnyObject]?
            
            AlamofireHelper.scrapeHTMLForURL("http://www.fueleconomy.gov/ws/rest/vehicle/menu/options?year=\(year)&make=\(make)&model=\(model)", responseHandler: handleLoadIDResponse, view: self.view)
            
            searchedModels = models
            searchBar.text = ""
            searchBar.selectedScopeButtonIndex = 0
            tableView.reloadData()
            hideTableView()
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
}
