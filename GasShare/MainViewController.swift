//
//  MainViewController.swift
//  GasShare
//
//  Created by Eric Kim on 7/23/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import MBProgressHUD
import SwiftyJSON
import Alamofire
import ConvenienceKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var mainToolbar: MainToolbar!
    @IBOutlet weak var gasMileageToolbar: GasMileageToolbar!
    @IBOutlet weak var gasPriceToolbar: GasPriceToolbar!
    @IBOutlet weak var mainToolbarHeight: NSLayoutConstraint!
    @IBOutlet weak var gasMileageToolbarHeight: NSLayoutConstraint!
    @IBOutlet weak var gasPriceToolbarHeight: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var startSearchBar: UISearchBar!
    @IBOutlet weak var endSearchBar: UISearchBar!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var currentLocationButtonBottomConstraint: NSLayoutConstraint!
    
    var screenHeight: CGFloat!
    var keyboardNotificationHandler = KeyboardNotificationHandler()
    var routeDistance: Double = -1
    var searchingStartLocation = true
    
    // map variables
    let locationManager = CLLocationManager()
    lazy var geocoder = GMSGeocoder()
    var placesClient: GMSPlacesClient!
    var mapView: GMSMapView!
    var startCoordinate = CLLocationCoordinate2D()
    var startLocation = ""
    var endCoordinate = CLLocationCoordinate2D()
    var endLocation = ""
    var startMarker: GMSMarker?
    var endMarker: GMSMarker?
    
    @IBAction func gasMileageButtonPressed(sender: AnyObject) {
        animate(gasMileageToolbar, over: mainToolbar)
    }

    
    @IBAction func gasPriceButtonPressed(sender: AnyObject) {
        animate(gasPriceToolbar, over: mainToolbar)
    }
    
    @IBAction func gasMileageDoneButtonPressed(sender: AnyObject) {
        animate(mainToolbar, over: gasMileageToolbar)
    }
    
    @IBAction func gasPriceDoneButtonPressed(sender: AnyObject) {
        animate(mainToolbar, over: gasPriceToolbar)
    }
    
    func animate(secondView: UIView, over firstView: UIView) {
        secondView.frame.origin.y = screenHeight
        secondView.hidden = false
        
        UIView.animateWithDuration(0.25) {
            secondView.frame.origin.y = self.screenHeight - secondView.frame.height
            
            self.view.layoutIfNeeded()
        }
        firstView.hidden = true
    }
    
    @IBAction func currentLocationButtonTapped(sender: AnyObject) {
        if let myLocation = mapView.myLocation {
            if searchingStartLocation {
                startCoordinate = myLocation.coordinate
            }
            else {
                endCoordinate = myLocation.coordinate
            }
            
            reverseGeocode(coordinate: myLocation.coordinate)
            currentLocationButton.selected = true
        }
        else {
            UIAlertView(title: "Sorry", message: "Could not find current location, please make sure that location features are enabled", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    @IBAction func gasMileageBackButtonTapped(sender: AnyObject) {
        animate(mainToolbar, over: gasMileageToolbar)
    }
    
    @IBAction func gasPriceBackButtonTapped(sender: AnyObject) {
        animate(mainToolbar, over: gasPriceToolbar)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.hidden = true
        
        screenHeight = self.view.frame.height
        
        mainToolbarHeight.constant = screenHeight * 0.16
        gasMileageToolbarHeight.constant = screenHeight * 0.25
        gasPriceToolbarHeight.constant = screenHeight * 0.33
        
        gasMileageToolbar.hidden = true
        gasPriceToolbar.hidden = true
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //camera's coordinates are dummy values
        let camera = GMSCameraPosition.cameraWithLatitude(40, longitude: -100, zoom: 3)
        mapView = GMSMapView.mapWithFrame(self.view.bounds, camera: camera)
        
        mapView.myLocationEnabled = true
        
        baseView.addSubview(mapView)
        
        startSearchBar.showsCancelButton = true
        endSearchBar.showsCancelButton = true
        
        endSearchBar.hidden = true
        distanceLabel.hidden = true
        
        keyboardNotificationHandler.keyboardWillBeHiddenHandler = { (height: CGFloat) in UIView.animateWithDuration(0.3) {
            self.currentLocationButtonBottomConstraint.constant = 10
            self.view.layoutIfNeeded()
            }
        }
        
        keyboardNotificationHandler.keyboardWillBeShownHandler = { (height: CGFloat) in UIView.animateWithDuration(0.4) {
            self.currentLocationButtonBottomConstraint.constant = (10 + height - self.mainToolbarHeight.constant)
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
    
//    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
//        //implement
//    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        //implement
//    }
    
    //MARK: Map Methods
    
    func moveCameraBetweenPoints(#coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) {
        let cameraUpdate = GMSCameraUpdate.fitBounds(GMSCoordinateBounds(coordinate: coordinate1, coordinate: coordinate2))
        
        mapView.animateWithCameraUpdate(cameraUpdate)
    }
    
    func setMarker(#coordinate: CLLocationCoordinate2D) {
        if let myLocation = mapView.myLocation {
            if coordinate.latitude != myLocation.coordinate.latitude && coordinate.longitude != myLocation.coordinate.longitude {
                currentLocationButton.selected = false
            }
        }
        
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

extension MainViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.alpha = 1.0
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.alpha = 1.0
        
        searchingStartLocation = (searchBar === startSearchBar)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.alpha = 0.8
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchForLocation(searchBar.text)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
