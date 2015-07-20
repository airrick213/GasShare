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
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startSearchBar: UISearchBar!
    @IBOutlet weak var endSearchBar: UISearchBar!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var useCurrentLocationButtonTopConstraint: NSLayoutConstraint!
    
    var gasMileage: Double!
    var gasPrice: Double!
    var routeDistance: Double = -1
    var searchingStartLocation = true
    
    // map variables
    let locationManager = CLLocationManager()
    let geocoder = GMSGeocoder()
    var placesClient: GMSPlacesClient!
    var mapView: GMSMapView!
    var startCoordinate = CLLocationCoordinate2D()
    var startLocation = ""
    var endCoordinate = CLLocationCoordinate2D()
    var endLocation = ""
    var startMarker: GMSMarker?
    var endMarker: GMSMarker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //camera's coordinates are dummy values
        let camera = GMSCameraPosition.cameraWithLatitude(40, longitude: -100, zoom: 3)
        mapView = GMSMapView.mapWithFrame(self.view.bounds, camera: camera)
        
        mapView.myLocationEnabled = true
        
        baseView.addSubview(mapView)
        
        endSearchBar.hidden = true
        useCurrentLocationButtonTopConstraint.constant = 0
        distanceLabel.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func useCurrentLocationButtonTapped(sender: AnyObject) {
        if let myLocation = mapView.myLocation {
            if searchingStartLocation {
                startCoordinate = myLocation.coordinate
            }
            else {
                endCoordinate = myLocation.coordinate
            }
            
            reverseGeocode(coordinate: myLocation.coordinate)
        }
        else {
            UIAlertView(title: "Sorry", message: "Could not find current location, please make sure that location features are enabled", delegate: nil, cancelButtonTitle: "OK").show()
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
                startLocation = ""
            
                if thoroughfare.count > 1 {
                    startLocation = " ".join(thoroughfare) + ", "
                }
            
                startLocation += ", ".join(location)
            
                startCoordinate.latitude = latitude!
                startCoordinate.longitude = longitude!
                
                setMarker(coordinate: startCoordinate)
            }
            else {
                endLocation = ""
                
                if thoroughfare.count > 1 {
                    endLocation = " ".join(thoroughfare) + ", "
                }
                
                endLocation += ", ".join(location)
                
                endCoordinate.latitude = latitude!
                endCoordinate.longitude = longitude!
                
                setMarker(coordinate: endCoordinate)
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
            if startMarker == nil || endMarker == nil || distanceLabel.text == "Could not find distance" {
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
    
    //MARK: Map Methods
    
    func moveCameraBetweenPoints(#coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) {
        let cameraUpdate = GMSCameraUpdate.fitBounds(GMSCoordinateBounds(coordinate: coordinate1, coordinate: coordinate2))
        
        mapView.animateWithCameraUpdate(cameraUpdate)
    }
    
    func setMarker(#coordinate: CLLocationCoordinate2D) {
        if searchingStartLocation {
            startMarker?.map = nil
            
            startMarker = GMSMarker(position: coordinate)
            startMarker!.appearAnimation = kGMSMarkerAnimationPop
            
            startMarker!.title = self.startLocation
            
            startMarker!.map = mapView
        }
        else {
            endMarker?.map = nil
            
            endMarker = GMSMarker(position: coordinate)
            endMarker!.appearAnimation = kGMSMarkerAnimationPop
            
            endMarker!.title = self.endLocation
            
            endMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            
            endMarker!.map = mapView
        }
        
        if startMarker != nil && endMarker != nil {
            moveCameraBetweenPoints(coordinate1: startCoordinate, coordinate2: endCoordinate)
            
            calculateDistance(origin: startCoordinate, destination: endCoordinate)
        }
        else if startMarker != nil {
            MapHelper.moveCamera(mapView: mapView, coordinate: startCoordinate)
        }
        else {
            MapHelper.moveCamera(mapView: mapView, coordinate: endCoordinate)
        }
        
        checkSearchBar()
    }
    
    func checkSearchBar() {
        if searchingStartLocation {
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
    
    func reverseGeocode(#coordinate: CLLocationCoordinate2D) {
        self.geocoder.reverseGeocodeCoordinate(coordinate, completionHandler: { (result: GMSReverseGeocodeResponse?, error: NSError?) -> Void in
            if let address = result?.firstResult() {
                if self.searchingStartLocation {
                    self.startLocation = ""
                    
                    if let thoroughfare = address.thoroughfare {
                        self.startLocation += thoroughfare.capitalizedString
                    }
                    
                    if let locality = address.locality {
                        if !self.startLocation.isEmpty {
                            self.startLocation += ", "
                        }
                        
                        self.startLocation += locality.capitalizedString
                    }
                    
                    if let administrativeArea = address.administrativeArea {
                        if !self.startLocation.isEmpty {
                            self.startLocation += ", "
                        }
                        
                        self.startLocation += administrativeArea.capitalizedString
                    }
                    
                    self.startSearchBar.text = self.startLocation
                }
                else {
                    self.endLocation = ""
                    
                    if let thoroughfare = address.thoroughfare {
                        self.endLocation += thoroughfare.capitalizedString
                    }
                    
                    if let locality = address.locality {
                        if !self.endLocation.isEmpty {
                            self.endLocation += ", "
                        }
                        
                        self.endLocation += locality.capitalizedString
                    }
                    
                    if let administrativeArea = address.administrativeArea {
                        if !self.endLocation.isEmpty {
                            self.endLocation += ", "
                        }
                        
                        self.endLocation += administrativeArea.capitalizedString
                    }
                    
                    self.endSearchBar.text = self.endLocation
                }
            }
            
            self.setMarker(coordinate: coordinate)
        })
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
    }
    
}
