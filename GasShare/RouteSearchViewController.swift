//
//  RouteSearchViewController.swift
//  GasShare
//
//  Created by Eric Kim on 7/13/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import MBProgressHUD
import SwiftyJSON
import Alamofire

class RouteSearchViewController: UIViewController {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startSearchBar: UISearchBar!
    @IBOutlet weak var endSearchBar: UISearchBar!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var useCurrentLocationButtonTopConstraint: NSLayoutConstraint!
    
    var routeMapViewController: RouteMapViewController!
    var gasMileage: Double!
    var gasPrice: Double!
    var routeDistance: Double = -1
    var searchingStartLocation = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        routeMapViewController = self.childViewControllers.first as! RouteMapViewController
        containerView.addSubview(routeMapViewController.view)
        endSearchBar.hidden = true
        useCurrentLocationButtonTopConstraint.constant = 0
        distanceLabel.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func useCurrentLocationButtonTapped(sender: AnyObject) {
        if let myLocation = routeMapViewController.mapView.myLocation {
            routeMapViewController.reverseGeocode(coordinate: myLocation.coordinate)
        }
        else {
            UIAlertView(title: "Sorry", message: "Could not find current location, please make sure that location features are turned on", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    func searchForLocation(searchText: String) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let htmlString = searchText.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.allZeros, range: Range<String.Index>(start: searchText.startIndex, end: searchText.endIndex))
        let params = "address=\(htmlString)&key=AIzaSyCqna5DDHzVmJBuBYwC3WELjmq8EbGTnAQ"
        let requestString = "https://maps.googleapis.com/maps/api/geocode/json?\(params)"
        
        Alamofire.request(.POST, requestString, parameters: nil).responseJSON(options: .allZeros) { (_, response, data, error) -> Void in
            hud.hide(true)
            
            if AlamofireHelper.requestSucceeded(response, error: error) {
                self.handleLocationSearchResponse(data!)
            }
            else {
                UIAlertView(title: "Sorry", message: "Network request failed, check your connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
            }
        }
    }
    
    func handleLocationSearchResponse(data: AnyObject) {
        let json = JSON(data)
        
        if let result = json["results"][0].dictionary {
            let addressComponents = result["address_components"]!.array
            let thoroughfare = addressComponents!
                .filter { $0["types"][0] == "street_number" || $0["types"][0] == "route" }
                .map { $0["long_name"].string! }
            
            let location = addressComponents!
                .filter { $0["types"][0] == "locality" || $0["types"][0] == "administrative_area_level_1" }
                .map { $0["long_name"].string! }
            
            let latitude = result["geometry"]!["location"]["lat"].double
            let longitude = result["geometry"]!["location"]["lng"].double
            
            if searchingStartLocation {
                routeMapViewController.startLocation = ""
            
                if thoroughfare.count > 1 {
                    routeMapViewController.startLocation = " ".join(thoroughfare) + ", "
                }
            
                routeMapViewController.startLocation += ", ".join(location)
            
                routeMapViewController.startCoordinate.latitude = latitude!
                routeMapViewController.startCoordinate.longitude = longitude!
                
                routeMapViewController.startMarker?.map = nil
                
                routeMapViewController.setMarker(coordinate: routeMapViewController.startCoordinate)
            }
            else {
                routeMapViewController.endLocation = ""
                
                if thoroughfare.count > 1 {
                    routeMapViewController.endLocation = " ".join(thoroughfare) + ", "
                }
                
                routeMapViewController.endLocation += ", ".join(location)
                
                routeMapViewController.endCoordinate.latitude = latitude!
                routeMapViewController.endCoordinate.longitude = longitude!
                
                routeMapViewController.endMarker?.map = nil
                
                routeMapViewController.setMarker(coordinate: routeMapViewController.endCoordinate)
            }
            
            if routeMapViewController.startMarker != nil && routeMapViewController.endMarker != nil {
                calculateDistance(origin: routeMapViewController.startCoordinate, destination: routeMapViewController.endCoordinate)
            }
        }
    }
    
    //MARK: Calculating Distance
    
    func calculateDistance(#origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let apiKey = "AIzaSyBQG_Le3xsE49W7dprNafDCgZ0vhdWIytw"
        let originParam = "origins=\(origin.latitude),\(origin.longitude)"
        let destinationParam = "destinations=\(destination.latitude),\(destination.longitude)"
        let requestString = "https://maps.googleapis.com/maps/api/distancematrix/json?\(originParam)&\(destinationParam)&units=imperial&key=\(apiKey)"
        
        Alamofire.request(.POST, requestString, parameters: nil).responseJSON(options: .allZeros) { (_, response, data, error) -> Void in
            hud.hide(true)
            
            if AlamofireHelper.requestSucceeded(response, error: error) {
                self.handleDistanceCalculationResponse(data!)
            }
            else {
                UIAlertView(title: "Sorry", message: "Network request failed, check your connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
            }
        }
    }
    
    func handleDistanceCalculationResponse(data: AnyObject) {
        let json = JSON(data)
        
        if let result = json["rows"][0]["elements"][0]["distance"]["text"].string {
            distanceLabel.text = result
            
            let routeDistanceString = distanceLabel.text!.componentsSeparatedByString(" ")[0]
            let formattedString = NSString(string: routeDistanceString).stringByReplacingOccurrencesOfString(",", withString: "")
            routeDistance = NSString(string: formattedString).doubleValue
        }
        else {
            distanceLabel.text = "Could not find distance"
        }
        
        distanceLabel.hidden = false
    }
    
    //MARK: Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "RouteDistanceDone" {
            if self.routeMapViewController.startMarker == nil || self.routeMapViewController.endMarker == nil || distanceLabel.text == "Could not find distance" {
                let alert = UIAlertView()
                alert.title = "No Route Distance"
                alert.message = "Please select the start and end locations of your route"
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
            
            calculationViewController.gasMileage = gasMileage
            calculationViewController.gasPrice = gasPrice
            calculationViewController.routeDistance = routeDistance
        }
    }
    
}

extension RouteSearchViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.alpha = 1.0
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.alpha = 1.0
        
        searchingStartLocation = (searchBar === startSearchBar)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.alpha = 0.7
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchForLocation(searchBar.text)
        
        if searchBar === startSearchBar {
            if endSearchBar.hidden == true {
                endSearchBar.hidden = false
                endSearchBar.becomeFirstResponder()
                useCurrentLocationButtonTopConstraint.constant = 44
            }
            else {
                startSearchBar.resignFirstResponder()
            }
        }
        else {
            endSearchBar.resignFirstResponder()
        }
    }
    
}
