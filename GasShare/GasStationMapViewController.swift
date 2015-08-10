//
//  GasStationMapViewController.swift
//  GasShare
//
//  Created by Eric Kim on 7/24/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import MBProgressHUD
import SwiftyJSON
import Alamofire
import ConvenienceKit

class GasStationMapViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var currentLocationButtonBottomConstraint: NSLayoutConstraint!
    
    let keyboardNotificationHandler = KeyboardNotificationHandler()
    let stateAbbreviations = [
        "Alabama" : "AL",
        "Montana" : "MT",
        "Alaska" : "AK",
        "Nebraska" : "NE",
        "Arizona" : "AZ",
        "Nevada" : "NV",
        "Arkansas" : "AR",
        "New Hampshire" : "NH",
        "California" : "CA",
        "New Jersey" : "NJ",
        "Colorado" : "CO",
        "New Mexico" : "NM",
        "Connecticut" : "CT",
        "New York" : "NY",
        "Delaware" : "DE",
        "North Carolina" : "NC",
        "Florida" : "FL",
        "North Dakota" : "ND",
        "Georgia" : "GA",
        "Ohio" : "OH",
        "Hawaii" : "HI",
        "Oklahoma" : "OK",
        "Idaho" : "ID",
        "Oregon" : "OR",
        "Illinois" : "IL",
        "Pennsylvania" : "PA",
        "Indiana" : "IN",
        "Rhode Island" : "RI",
        "Iowa" : "IA",
        "South Carolina" : "SC",
        "Kansas"  : "KS",
        "South Dakota" : "SD",
        "Kentucky" : "KY",
        "Tennessee" : "TN",
        "Louisiana" : "LA",
        "Texas" : "TX",
        "Maine" : "ME",
        "Utah" : "UT",
        "Maryland" : "MD",
        "Vermont" : "VT",
        "Massachusetts" : "MA",
        "Virginia" : "VA",
        "Michigan" : "MI",
        "Washington" : "WA",
        "Minnesota" : "MN",
        "West Virginia" : "WV",
        "Mississippi" : "MS",
        "Wisconsin" : "WI",
        "Missouri" : "MO",
        "Wyoming" : "WY"]
    
    // map variables
    let locationManager = CLLocationManager()
    let geocoder = GMSGeocoder()
    var placesClient: GMSPlacesClient!
    var mapView: GMSMapView!
    var selectedLocation = ""
    var firstLocation = true
    var defaultLocation = ""
    var zipcode: String? = nil
    
    @IBAction func currentLocationButtonPressed(sender: AnyObject) {
        if let myLocation = mapView.myLocation {
            MapHelper.moveCamera(mapView: mapView, coordinate: myLocation.coordinate)
            reverseGeocode(coordinate: myLocation.coordinate)
            
            currentLocationButton.selected = true
            searchBar.resignFirstResponder()
        }
        else {
            UIAlertView(title: "Sorry", message: "Could not find current location, please make sure that location features are enabled", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.barTintColor = UIColor(red: 91.0/255.0, green: 202.0/255.0, blue: 1.0, alpha: 1.0)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //camera's coordinates are dummy values
        let camera = GMSCameraPosition.cameraWithLatitude(40, longitude: -100, zoom: 3)
        mapView = GMSMapView.mapWithFrame(self.view.bounds, camera: camera)
        
        mapView.delegate = self
        
        mapView.myLocationEnabled = true
        
        baseView.addSubview(mapView)
                
        keyboardNotificationHandler.keyboardWillBeHiddenHandler = { (height: CGFloat) in UIView.animateWithDuration(0.3) {
            self.currentLocationButtonBottomConstraint.constant = 14
            self.view.layoutIfNeeded()
            }
        }
        
        keyboardNotificationHandler.keyboardWillBeShownHandler = { (height: CGFloat) in UIView.animateWithDuration(0.4) {
            self.currentLocationButtonBottomConstraint.constant = 14 + height
            self.view.layoutIfNeeded()
            }
        }
        
        if !defaultLocation.isEmpty {
            searchBar.text = defaultLocation
            searchForLocation(searchBar.text)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchForLocation(searchText: String) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let htmlString = searchText.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.allZeros, range: Range<String.Index>(start: searchText.startIndex, end: searchText.endIndex))
        let params = "address=\(htmlString)&key=AIzaSyCqna5DDHzVmJBuBYwC3WELjmq8EbGTnAQ"
        let requestString = "https://maps.googleapis.com/maps/api/geocode/json?\(params)"
        
        Alamofire.request(.POST, requestString, parameters: nil).responseJSON(options: .allZeros) { (_, response, data, error) -> Void in
            hud.hide(true)
            
            if AlamofireHelper.requestSucceeded(response, error: error) {
                self.handleSearchLocationResponse(data!)
            }
            else {
                UIAlertView(title: "Sorry", message: "Network request failed, check your connection and try again", delegate: nil, cancelButtonTitle: "OK").show()
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
        }
    }
    
    func handleSearchLocationResponse(data: AnyObject) {
        let json = JSON(data)
        
        if let result = json["results"][0].dictionary {
            let latitude = result["geometry"]!["location"]["lat"].double
            let longitude = result["geometry"]!["location"]["lng"].double
            
            let selectedCoordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            
            MapHelper.moveCamera(mapView: mapView, coordinate: selectedCoordinate)
            
            reverseGeocode(coordinate: selectedCoordinate)
        }
    }
    
    //MARK: Map Methods
    
    func setMarker(#coordinate: CLLocationCoordinate2D) {
        if let myLocation = mapView.myLocation {
            if coordinate.latitude != myLocation.coordinate.latitude && coordinate.longitude != myLocation.coordinate.longitude {
                currentLocationButton.selected = false
            }
        }
        
        mapView.clear()
        
        let marker = GMSMarker(position: coordinate)
        marker.appearAnimation = kGMSMarkerAnimationPop
        
        marker.title = self.selectedLocation
        
        marker.map = mapView
    }
    
    func reverseGeocode(#coordinate: CLLocationCoordinate2D) {
        self.geocoder.reverseGeocodeCoordinate(coordinate, completionHandler: { (result: GMSReverseGeocodeResponse?, error: NSError?) -> Void in
            if let address = result?.firstResult() {
                self.selectedLocation = ""
                
                if let locality = address.locality {
                    self.selectedLocation += locality.capitalizedString
                }
                
                if let administrativeArea = address.administrativeArea {
                    if !self.selectedLocation.isEmpty {
                        self.selectedLocation += ", "
                    }
                    
                    self.selectedLocation += self.stateAbbreviations[administrativeArea.capitalizedString]!
                }
                
                if let postalCode = address.postalCode {
                    self.zipcode = postalCode
                }
                else {
                    self.zipcode = nil
                }
                
                self.searchBar.text = self.selectedLocation
            }
            
            self.setMarker(coordinate: coordinate)
        })
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "GasStationDone" {
            if selectedLocation == "" {
                UIAlertView(title: "No Location Selected", message: "Please select the location of your gas station", delegate: nil, cancelButtonTitle: "OK").show()
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                return false
            }
        }
        return true
    }
    
}

extension GasStationMapViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.alpha = 1.0
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.alpha = 1.0
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.alpha = 0.8
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchForLocation(searchBar.text)
        
        searchBar.resignFirstResponder()
    }
    
}

extension GasStationMapViewController: GMSMapViewDelegate {
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
            searchForLocation(searchBar.text)
        }
        else {
            reverseGeocode(coordinate: coordinate)
        }
    }
    
}
