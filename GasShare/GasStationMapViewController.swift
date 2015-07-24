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
    
    // map variables
    let locationManager = CLLocationManager()
    let geocoder = GMSGeocoder()
    var placesClient: GMSPlacesClient!
    var mapView: GMSMapView!
    var selectedCoordinate = CLLocationCoordinate2D()
    var selectedLocation = ""
    var firstLocation = true
    var usedSearchBar = false
    
    @IBAction func currentLocationButtonPressed(sender: AnyObject) {
        if let myLocation = mapView.myLocation {
            MapHelper.moveCamera(mapView: mapView, coordinate: myLocation.coordinate)
            setMarker(coordinate: myLocation.coordinate)
            
            currentLocationButton.selected = true
            searchBar.resignFirstResponder()
        }
        else {
            UIAlertView(title: "Sorry", message: "Could not find current location, please make sure that location features are enabled", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //camera's coordinates are dummy values
        let camera = GMSCameraPosition.cameraWithLatitude(40, longitude: -100, zoom: 3)
        mapView = GMSMapView.mapWithFrame(self.view.bounds, camera: camera)
        
        mapView.delegate = self
        
        mapView.myLocationEnabled = true
        
        baseView.addSubview(mapView)
        
        searchBar.showsCancelButton = true
        
        keyboardNotificationHandler.keyboardWillBeHiddenHandler = { (height: CGFloat) in UIView.animateWithDuration(0.3) {
            self.currentLocationButtonBottomConstraint.constant = 10
            self.view.layoutIfNeeded()
            }
        }
        
        keyboardNotificationHandler.keyboardWillBeShownHandler = { (height: CGFloat) in UIView.animateWithDuration(0.4) {
            self.currentLocationButtonBottomConstraint.constant = 10 + height
            self.view.layoutIfNeeded()
            }
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
                UIAlertView(title: "Sorry", message: "Network request failed, check your connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
            }
        }
    }
    
    func handleSearchLocationResponse(data: AnyObject) {
        let json = JSON(data)
        
        if let result = json["results"][0].dictionary {
            let addressComponents = result["address_components"]!.array
            let location = addressComponents!
                .filter { $0["types"][0] == "locality" || $0["types"][0] == "administrative_area_level_1" }
                .map { $0["short_name"].string! }
            
            selectedLocation = ", ".join(location)
            
            let latitude = result["geometry"]!["location"]["lat"].double
            let longitude = result["geometry"]!["location"]["lng"].double
            
            selectedCoordinate.latitude = latitude!
            selectedCoordinate.longitude = longitude!
            
            usedSearchBar = true
            MapHelper.moveCamera(mapView: mapView, coordinate: selectedCoordinate)
        }
    }
    
    //MARK: Map Methods
    
    func setMarker(#coordinate: CLLocationCoordinate2D) {
        if let myLocation = mapView.myLocation {
            if coordinate.latitude != myLocation.coordinate.latitude && coordinate.longitude != myLocation.coordinate.longitude {
                currentLocationButton.selected = false
            }
        }
        
        self.selectedCoordinate = coordinate
        
        if usedSearchBar {
            usedSearchBar = false
        }
        else {
            reverseGeocode(coordinate: coordinate)
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
                    
                    self.selectedLocation += administrativeArea.capitalizedString
                }
            }
        })
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
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

extension GasStationMapViewController: GMSMapViewDelegate {
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        MapHelper.moveCamera(mapView: mapView, coordinate: coordinate)
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        if !firstLocation {
            setMarker(coordinate: position.target)
        }
        else {
            firstLocation = false
        }
    }
    
}