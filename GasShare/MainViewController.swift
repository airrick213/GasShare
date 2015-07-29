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
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var startSearchBar: UISearchBar!
    @IBOutlet weak var endSearchBar: UISearchBar!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var currentLocationButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var gasPriceTextField: UITextField!
    @IBOutlet weak var gasMileageTextField: UITextField!
    @IBOutlet weak var gasMileageToolbarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var gasPriceToolbarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var gasPriceButton: UIButton!
    @IBOutlet weak var gasMileagesSuggestionsButton: UIButton!
    @IBOutlet weak var regularGasButton: UIButton!
    @IBOutlet weak var plusGasButton: UIButton!
    @IBOutlet weak var premiumGasButton: UIButton!
    @IBOutlet weak var gasMileageToolbarButton: UIButton!
    @IBOutlet weak var gasPriceToolbarButton: UIButton!
    @IBOutlet weak var gasMileageToolbarButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var gasPriceToolbarButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var calculateButtonHeight: NSLayoutConstraint!
    
    var screenHeight: CGFloat!
    var keyboardNotificationHandler = KeyboardNotificationHandler()
    var routeDistance: Double?
    var searchingStartLocation = true
    
    //gas mileage variables
    var gasMileageText = "Don't know the gas mileage?"
    var gasMileage: Double?
    var selectedIndex: Int?
    
    //map variables
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
    
    //gas price variables
    var selectedLocation = ""
    var zipcode = ""
    var regPrice: Double = 0
    var plusPrice: Double = 0
    var prePrice: Double = 0
    var gasPrice: Double?
    
    @IBAction func gasMileageButtonPressed(sender: AnyObject) {
        animate(gasMileageToolbar, over: mainToolbar)
    }

    
    @IBAction func gasPriceButtonPressed(sender: AnyObject) {
        animate(gasPriceToolbar, over: mainToolbar)
    }
    
    @IBAction func gasMileageDoneButtonPressed(sender: AnyObject) {
        if !gasMileageTextField.text.isEmpty || !gasMileageTextField.enabled {
            if gasMileageTextField.enabled {
                gasMileage = NSString(string: gasMileageTextField.text).doubleValue
            }
            else {
                let doubleString = gasMileageText.substringFromIndex(advance(gasMileageText.startIndex, count(gasMileageText) - 2))
                gasMileage = NSString(string: doubleString).doubleValue
            }
            
            gasMileageTextField.resignFirstResponder()
            animate(mainToolbar, over: gasMileageToolbar)
            
            gasMileageToolbarButton.setTitle("\(gasMileage!) mi/gal", forState: UIControlState.Normal)
            gasMileageToolbarButton.titleLabel!.font = UIFont(name: "Avenir", size: 24)
            updateCalculateButton()
            
            if let gasMileage = gasMileage {
                gasMileageTextField.text = String(format: "%.1f", gasMileage)
            }
        }
        else {
            UIAlertView(title: "No Gas Mileage", message: "Please enter your car's gas mileage or choose one from the suggestions list", delegate: nil, cancelButtonTitle: "OK").show()
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }
    }
    
    @IBAction func gasPriceDoneButtonPressed(sender: AnyObject) {
        if !gasPriceTextField.text.isEmpty || !gasPriceTextField.enabled {
            if gasPriceTextField.enabled {
                gasPrice = NSString(string: gasPriceTextField.text).doubleValue
            }
            else {
                let gasPriceText = gasPriceButton.titleLabel!.text!
                let doubleString = gasPriceText.substringFromIndex(advance(gasPriceText.startIndex, count(gasPriceText) - 4))
                gasPrice = NSString(string: doubleString).doubleValue
            }
            
            gasPriceTextField.resignFirstResponder()
            animate(mainToolbar, over: gasPriceToolbar)
            
            let priceString = NSString(format: "$%.2f/gal", gasPrice!) as String
            gasPriceToolbarButton.setTitle(priceString, forState: UIControlState.Normal)
            gasPriceToolbarButton.titleLabel!.font = UIFont(name: "Avenir", size: 24)
            updateCalculateButton()
            
            if let gasPrice = gasPrice {
                gasPriceTextField.text = String(format: "%.2f", gasPrice)
            }
        }
        else {
            UIAlertView(title: "No Gas Price", message: "Please enter the gas price or select the location of your gas station", delegate: nil, cancelButtonTitle: "OK").show()
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }
    }
    
    func animate(secondView: UIView, over firstView: UIView) {
        secondView.frame.origin.y = screenHeight
        secondView.hidden = false
        
        firstView.hidden = true
        
        UIView.animateWithDuration(0.25) {
            secondView.frame.origin.y = self.screenHeight - secondView.frame.height
            
            self.view.layoutIfNeeded()
        }
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
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }
    }
    
    @IBAction func gasMileageBackButtonTapped(sender: AnyObject) {
        gasMileageTextField.resignFirstResponder()
        animate(mainToolbar, over: gasMileageToolbar)
        gasMileagesSuggestionsButton.setTitle(gasMileageText, forState: UIControlState.Normal)
        if gasMileageText != "Don't know the gas mileage?" {
            gasMileageTextField.enabled = false
            if let gasMileage = gasMileage {
                gasMileageTextField.text = String(format: "%.1f", gasMileage)
            }
            else {
                gasMileageTextField.text = ""
            }
        }
    }
    
    @IBAction func gasPriceBackButtonTapped(sender: AnyObject) {
        gasPriceTextField.resignFirstResponder()
        animate(mainToolbar, over: gasPriceToolbar)
        if selectedLocation != "" {
            if regularGasButton.selected == true {
                reloadGasPriceButtonText(regPrice)
            }
            else if plusGasButton.selected == true {
                reloadGasPriceButtonText(plusPrice)
            }
            else {
                reloadGasPriceButtonText(prePrice)
            }
            
            showGasPriceButtons()
            
            gasPriceTextField.enabled = false
            if let gasPrice = gasPrice {
                gasPriceTextField.text = String(format: "%.2f", gasPrice)
            }
            else {
                gasPriceTextField.text = ""
            }
        }
    }
    
    @IBAction func regularGasButtonTapped(sender: AnyObject) {
        reloadGasPriceButtonText(regPrice)
        
        regularGasButton.selected = true
        plusGasButton.selected = false
        premiumGasButton.selected = false
    }
    
    @IBAction func plusGasButtonTapped(sender: AnyObject) {
        reloadGasPriceButtonText(plusPrice)
        
        regularGasButton.selected = false
        plusGasButton.selected = true
        premiumGasButton.selected = false
    }
    
    @IBAction func premiumGasButtonTapped(sender: AnyObject) {
        reloadGasPriceButtonText(prePrice)
        
        regularGasButton.selected = false
        plusGasButton.selected = false
        premiumGasButton.selected = true
    }
    
    @IBAction func gasMileageClearButtonTapped(sender: AnyObject) {
        gasMileagesSuggestionsButton.setTitle("Don't know the gas mileage?", forState: UIControlState.Normal)
        gasMileageTextField.enabled = true
        selectedIndex = nil
    }
    
    @IBAction func gasPriceClearButtonTapped(sender: AnyObject) {
        gasPriceButton.setTitle("Don't know the gas price?", forState: UIControlState.Normal)
        hideGasPriceButtons()
        gasPriceTextField.enabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calculateButton.hidden = true
        
        screenHeight = self.view.frame.height
        
        mainToolbarHeight.constant = screenHeight * 0.16
        gasMileageToolbarHeight.constant = screenHeight * 0.25
        gasPriceToolbarHeight.constant = screenHeight * 0.32
        
        gasMileageToolbar.hidden = true
        gasPriceToolbar.hidden = true
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //camera's coordinates are dummy values
        let camera = GMSCameraPosition.cameraWithLatitude(40, longitude: -100, zoom: 3)
        mapView = GMSMapView.mapWithFrame(self.view.bounds, camera: camera)
        
        mapView.myLocationEnabled = true
        mapView.delegate = self
        
        baseView.addSubview(mapView)
        
        startSearchBar.showsCancelButton = true
        endSearchBar.showsCancelButton = true
        
        endSearchBar.hidden = true
        distanceLabel.hidden = true
        
        hideGasPriceButtons()
        
        keyboardNotificationHandler.keyboardWillBeHiddenHandler = { (height: CGFloat) in UIView.animateWithDuration(0.3) {
                if self.gasMileageTextField.isFirstResponder() {
                    self.gasMileageToolbarBottomConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }
                else if self.gasPriceTextField.isFirstResponder() {
                    self.gasPriceToolbarBottomConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }
                else {
                    self.currentLocationButtonBottomConstraint.constant = 10
                    self.view.layoutIfNeeded()
                }
            }
        }
    
        keyboardNotificationHandler.keyboardWillBeShownHandler = { (height: CGFloat) in UIView.animateWithDuration(0.4) {
                if self.gasMileageTextField.isFirstResponder() {
                    self.gasMileageToolbarBottomConstraint.constant = height
                    self.view.layoutIfNeeded()
                }
                else if self.gasPriceTextField.isFirstResponder() {
                    self.gasPriceToolbarBottomConstraint.constant = height
                    self.view.layoutIfNeeded()
                }
                else {
                    self.currentLocationButtonBottomConstraint.constant = (10 + height - self.mainToolbarHeight.constant)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateCalculateButton() {
        if routeDistance != nil && gasMileage != nil && gasPrice != nil {
            calculateButton.hidden = false
            gasMileageToolbarButtonBottomConstraint.constant = 10 + screenHeight * 0.09
            gasPriceToolbarButtonBottomConstraint.constant = 10 + screenHeight * 0.09
            mainToolbarHeight.constant = gasMileageToolbarHeight.constant
            calculateButtonHeight.constant = mainToolbarHeight.constant - gasMileageToolbarButton.frame.origin.y - gasMileageToolbarButton.frame.height - 10 - 10
        }
    }
    
    //MARK: Finding Location

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
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
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
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
        }
    }
    
    func handleDistanceCalculationResponse(data: AnyObject) {
        let json = JSON(data)
        
        if let result = json["rows"][0]["elements"][0]["distance"]["text"].string {
            distanceLabel.text = result
            
            let distanceLabelComponents = distanceLabel.text!.componentsSeparatedByString(" ")
            let routeDistanceString = distanceLabelComponents[0]
            let formattedString = NSString(string: routeDistanceString).stringByReplacingOccurrencesOfString(",", withString: "")
            routeDistance = NSString(string: formattedString).doubleValue
            
            if distanceLabelComponents[1] == "ft" {
                routeDistance! *= 0.000189
            }
            
            updateCalculateButton()
        }
        else {
            distanceLabel.text = "Could not find distance"
        }
        
        distanceLabel.hidden = false
    }
    
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
    
    //MARK: Gas Price Code
    
    func searchForZipcode() {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let locationArray = selectedLocation.componentsSeparatedByString(", ")
        if locationArray.count < 2 {
            UIAlertView(title: "Sorry", message: "Could not find city or state, please select a different location", delegate: nil, cancelButtonTitle: "OK").show()
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
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
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
        }
    }
    
    func handleSearchZipcodeResponse(data: AnyObject) {
        let json = JSON(data)
        
        if let result = json["zip_codes"].array {
            if result.count > 0 {
                self.zipcode = result[0].string!
                findGasPrice()
            }
            else {
                UIAlertView(title: "Sorry", message: "Could not find zipcode, please select a different location", delegate: nil, cancelButtonTitle: "OK").show()
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
        }
    }
    
    func findGasPrice() {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let requestString = "http://www.motortrend.com/gas_prices/34/\(zipcode)/"
        
        Alamofire.request(.GET, requestString, parameters: nil).responseString { (_, response, data, error) -> Void in
            hud.hide(true)
            
            if AlamofireHelper.requestSucceeded(response, error: error) {
                self.handleFindGasPriceResponse(data!)
            }
            else {
                self.gasPriceButton.setTitle("\(self.selectedLocation): Gas price could not be found", forState: UIControlState.Normal)
                
                self.hideGasPriceButtons()
            }
        }
    }
    
    func handleFindGasPriceResponse(data: AnyObject) {
        let html = data as! String
        
        var error: NSError?
        var parser = HTMLParser(html: html, error: &error)
        
        if error != nil {
            UIAlertView(title: "Sorry", message: "Network request failed, check your connection and try again.", delegate: nil, cancelButtonTitle: "OK").show()
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            self.gasPriceButton.setTitle("\(self.selectedLocation): Gas price could not be found", forState: UIControlState.Normal)
            hideGasPriceButtons()
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
        reloadGasPriceButtonText(regPrice)
        
        regularGasButton.selected = true
        plusGasButton.selected = false
        premiumGasButton.selected = false
        
        showGasPriceButtons()
    }
    
    func showGasPriceButtons() {
        regularGasButton.hidden = false
        plusGasButton.hidden = false
        premiumGasButton.hidden = false
        
        gasPriceToolbarHeight.constant = screenHeight * 0.32
    }
    
    func hideGasPriceButtons() {
        regularGasButton.hidden = true
        plusGasButton.hidden = true
        premiumGasButton.hidden = true
        
        gasPriceToolbarHeight.constant = gasMileageToolbarHeight.constant
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
    
    func reloadGasPriceButtonText(price: Double) {
        if price == 0 {
            gasPriceButton.setTitle("\(selectedLocation): Gas price could not be found", forState: UIControlState.Normal)
        }
        else {
            let priceString = NSString(format: "\(selectedLocation): $%.2f", price) as String
            gasPriceButton.setTitle(priceString, forState: UIControlState.Normal)
        }
        
        gasPriceButton.sizeToFit()
    }
    
    //MARK: Navigation
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        if let identifier = segue.identifier {
            if identifier == "GasMileageDone" {
                let source = segue.sourceViewController as! GasMileagesViewController
                
                if let selectedIndex = source.selectedIndex {
                    if gasMileageText != source.suggestedMileageValues[selectedIndex] {
                        gasMileageText = source.suggestedMileageValues[selectedIndex]
                        gasMileagesSuggestionsButton.setTitle(gasMileageText, forState: UIControlState.Normal)
                        gasMileageTextField.enabled = false
                        
                        gasMileagesSuggestionsButton.sizeToFit()
                    }
                }
                else if gasMileagesSuggestionsButton.titleLabel!.text != "Don't know the gas mileage?" {
                    gasMileageText = "Don't know the gas mileage?"
                    gasMileagesSuggestionsButton.setTitle(gasMileageText, forState: UIControlState.Normal)
                    gasMileageTextField.enabled = true
                    
                    gasMileagesSuggestionsButton.sizeToFit()
                }
                
                selectedIndex = source.selectedIndex
            }
            else if identifier == "GasMileageCancel" {
                gasMileagesSuggestionsButton.setTitle(gasMileageText, forState: UIControlState.Normal)
                gasMileageTextField.enabled = (gasMileageText == "Don't know the gas mileage?")
            }
            else if identifier == "GasStationDone" {
                let source = segue.sourceViewController as! GasStationMapViewController
                
                selectedLocation = source.selectedLocation
                
                searchForZipcode()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "ShowGasMileagesSuggestions" {
                let gasMileagesViewController = segue.destinationViewController as! GasMileagesViewController
                
                if let selectedIndex = selectedIndex {
                    gasMileagesViewController.selectedIndex = selectedIndex
                }
            }
            else if identifier == "ShowCalculation" {
                let calculationViewController = segue.destinationViewController as! CalculationViewController
                
                calculationViewController.routeDistance = routeDistance!
                calculationViewController.gasMileage = gasMileage!
                calculationViewController.gasPrice = gasPrice!
            }
        }
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

extension MainViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.text.rangeOfString(".") != nil {
            if (string.rangeOfString(".") != nil || count(textField.text.componentsSeparatedByString(".")[1]) + count(string) > 2) {
                return false
            }
        }
        
        return true
    }
    
}

extension MainViewController: GMSMapViewDelegate {
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        if startSearchBar.isFirstResponder() {
            startSearchBar.resignFirstResponder()
        }
        else if endSearchBar.isFirstResponder() {
            endSearchBar.resignFirstResponder()
        }
        else if gasMileageTextField.isFirstResponder() {
            gasMileageTextField.resignFirstResponder()
        }
        else if gasPriceTextField.isFirstResponder() {
            gasPriceTextField.resignFirstResponder()
        }
    }
    
}
