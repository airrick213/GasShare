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
    
    @IBOutlet weak var startSearchBar: UISearchBar!
    @IBOutlet weak var endSearchBar: UISearchBar!
    @IBOutlet weak var containerView: UIView!
    var routeMapViewController: RouteMapViewController!
    var gasMileage: Int!
    var gasPrice: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        routeMapViewController = self.childViewControllers.first as! RouteMapViewController
        containerView.addSubview(routeMapViewController.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchForLocation(searchText: String, searchingStartLocation: Bool) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let htmlString = searchText.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.allZeros, range: Range<String.Index>(start: searchText.startIndex, end: searchText.endIndex))
        let params = "address=\(htmlString)&key=AIzaSyCqna5DDHzVmJBuBYwC3WELjmq8EbGTnAQ"
        let requestString = "https://maps.googleapis.com/maps/api/geocode/json?\(params)"
        
        Alamofire.request(.POST, requestString, parameters: nil).responseJSON(options: .allZeros) { (_, response, data, error) -> Void in
            hud.hide(true)
            
            if self.requestSucceeded(response, error: error) {
                self.handleResponse(data!, searchingStartLocation: searchingStartLocation)
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
    
    func handleResponse(data: AnyObject, searchingStartLocation: Bool) {
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
            
                routeMapViewController.moveCamera(coordinate: routeMapViewController.startCoordinate)
                
                routeMapViewController.startMarker?.map = nil
                
                routeMapViewController.setMarker(searchingStartLocation: true)
            }
            else {
                routeMapViewController.endLocation = ""
                
                if thoroughfare.count > 1 {
                    routeMapViewController.endLocation = " ".join(thoroughfare) + ", "
                }
                
                routeMapViewController.endLocation += ", ".join(location)
                
                routeMapViewController.endCoordinate.latitude = latitude!
                routeMapViewController.endCoordinate.longitude = longitude!
                
                routeMapViewController.moveCamera(coordinate: routeMapViewController.endCoordinate)
                
                routeMapViewController.endMarker?.map = nil
                
                routeMapViewController.setMarker(searchingStartLocation: false)
            }
        }
    }
    
}

extension RouteSearchViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.alpha = 1.0
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.alpha = 1.0
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.alpha = 0.7
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchForLocation(searchBar.text, searchingStartLocation: (searchBar === startSearchBar))
    }
    
}
