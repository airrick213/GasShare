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
import Kanna

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
    @IBOutlet weak var gasMileageButton: UIButton!
    @IBOutlet weak var regularGasButton: UIButton!
    @IBOutlet weak var plusGasButton: UIButton!
    @IBOutlet weak var premiumGasButton: UIButton!
    @IBOutlet weak var gasMileageToolbarButton: UIButton!
    @IBOutlet weak var gasPriceToolbarButton: UIButton!
    @IBOutlet weak var gasMileageToolbarButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var gasPriceToolbarButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var calculateButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var gasPriceClearButton: UIButton!
    @IBOutlet weak var gasMileageClearButton: UIButton!
    @IBOutlet weak var gasMileageDoneButton: UIButton!
    @IBOutlet weak var gasPriceDoneButton: UIButton!
    @IBOutlet weak var plusGasButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var plusGasButtonTopConstraint: NSLayoutConstraint!
    
    var user = User()
    
    var screenHeight: CGFloat!
    let mainToolbarHeightConstant: CGFloat = 100
    let gasMileageToolbarHeightConstant: CGFloat = 160
    let gasPriceToolbarHeightConstant: CGFloat = 210
    
    var keyboardNotificationHandler = KeyboardNotificationHandler()
    var searchingStartLocation = true
    
    //gas mileage variables
    var gasMileageText = "Don't know the gas mileage?"
    
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
    var didChangeSearchBarText = false
    
    //gas price variables
    var selectedLocation = ""
    var zipcode = ""
    var regPrice: Double = 0
    var plusPrice: Double = 0
    var prePrice: Double = 0
    
    @IBAction func gasMileageButtonPressed(sender: AnyObject) {
        animate(gasMileageToolbar, over: mainToolbar)
    }

    
    @IBAction func gasPriceButtonPressed(sender: AnyObject) {
        animate(gasPriceToolbar, over: mainToolbar)
    }
    
    @IBAction func gasMileageDoneButtonPressed(sender: AnyObject) {
        if !gasMileageTextField.text!.isEmpty || !gasMileageTextField.enabled {
            if gasMileageTextField.enabled {
                user.gasMileage = NSString(string: gasMileageTextField.text!).doubleValue
            }
            else {
                user.gasMileage = NSString(string: gasMileageText).doubleValue
            }
            
            if user.gasMileage > 0 {
                gasMileageTextField.resignFirstResponder()
                animate(mainToolbar, over: gasMileageToolbar)
                
                gasMileageToolbarButton.setTitle("\(user.gasMileage!) mi/gal", forState: UIControlState.Normal)
                gasMileageToolbarButton.selected = true
                updateCalculateButton()
                
                gasMileageTextField.text = String(format: "%.1f", user.gasMileage!)
            }
            else {
                UIAlertView(title: "No Gas Mileage", message: "Please enter your car's gas mileage or select your car model", delegate: nil, cancelButtonTitle: "OK").show()
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
        }
        else {
            UIAlertView(title: "No Gas Mileage", message: "Please enter your car's gas mileage or select your car model", delegate: nil, cancelButtonTitle: "OK").show()
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }
    }
    
    @IBAction func gasPriceDoneButtonPressed(sender: AnyObject) {
        if !gasPriceTextField.text!.isEmpty || !gasPriceTextField.enabled {
            if gasPriceTextField.enabled {
                user.gasPrice = NSString(string: gasPriceTextField.text!).doubleValue
            }
            else {
                let gasPriceText = gasPriceButton.titleLabel!.text!
                let doubleString = gasPriceText.substringFromIndex(gasPriceText.startIndex.advancedBy(gasPriceText.characters.count - 4))
                user.gasPrice = NSString(string: doubleString).doubleValue
            }
            
            if user.gasPrice > 0 {
                gasPriceTextField.resignFirstResponder()
                animate(mainToolbar, over: gasPriceToolbar)
                
                let priceString = NSString(format: "$%.2f/gal", user.gasPrice!) as String
                gasPriceToolbarButton.setTitle(priceString, forState: UIControlState.Normal)
                gasPriceToolbarButton.selected = true
                updateCalculateButton()
                
                gasPriceTextField.text = String(format: "%.2f", user.gasPrice!)
            }
            else {
                UIAlertView(title: "No Gas Price", message: "Please enter the gas price or select the location of your gas station", delegate: nil, cancelButtonTitle: "OK").show()
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
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
            
            if secondView === self.mainToolbar {
                self.currentLocationButtonBottomConstraint.constant = 14
            }
            else {
                self.currentLocationButtonBottomConstraint.constant = 14 + secondView.frame.height - firstView.frame.height
            }
            
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
        
        if gasMileageButton.titleLabel!.text != "Don't know the gas mileage?" {
            gasMileageButton.setTitle("\(gasMileageText) mi/gal", forState: UIControlState.Normal)
            
            gasMileageTextField.enabled = false
            
            if let gasMileage = user.gasMileage {
                gasMileageTextField.text = gasMileageText
            }
            else {
                gasMileageTextField.text = ""
            }
            
            gasMileageClearButton.hidden = false
        }
        else {
            gasMileageButton.setTitle("Don't know the gas mileage?", forState: UIControlState.Normal)
            
            gasMileageTextField.enabled = true
            
            
            gasMileageClearButton.hidden = true
        }
    }
    
    @IBAction func gasPriceBackButtonTapped(sender: AnyObject) {
        gasPriceTextField.resignFirstResponder()
        animate(mainToolbar, over: gasPriceToolbar)
        if !regularGasButton.hidden {
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
            if let gasPrice = user.gasPrice {
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
        gasMileageButton.setTitle("Don't know the gas mileage?", forState: UIControlState.Normal)
        gasMileageTextField.enabled = true
        gasMileageClearButton.hidden = true
    }
    
    @IBAction func gasPriceClearButtonTapped(sender: AnyObject) {
        gasPriceButton.setTitle("Don't know the gas price?", forState: UIControlState.Normal)
        hideGasPriceButtons()
        gasPriceTextField.enabled = true
        gasPriceClearButton.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if NSUserDefaults.standardUserDefaults().boolForKey("usedAppBefore") {
            UIAlertView(title: "Helpful Tip", message: "You can use your current location both before you leave and after you arrive to get your route's start and end locations.", delegate: nil, cancelButtonTitle: "OK")
        }
        
        calculateButton.hidden = true
        
        screenHeight = self.view.frame.height
        
        mainToolbarHeight.constant = mainToolbarHeightConstant
        gasMileageToolbarHeight.constant = gasMileageToolbarHeightConstant
        gasPriceToolbarHeight.constant = gasPriceToolbarHeightConstant
        
        gasMileageToolbar.hidden = true
        gasPriceToolbar.hidden = true
        
        gasMileageDoneButton.titleLabel!.adjustsFontSizeToFitWidth = true
        gasPriceDoneButton.titleLabel!.adjustsFontSizeToFitWidth = true
        
        startSearchBar.barTintColor = UIColor(red: 91.0/255.0, green: 202.0/255.0, blue: 1.0, alpha: 1.0)

        endSearchBar.barTintColor = UIColor(red: 91.0/255.0, green: 202.0/255.0, blue: 1.0, alpha: 1.0)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //camera's coordinates are dummy values
        let camera = GMSCameraPosition.cameraWithLatitude(40, longitude: -100, zoom: 3)
        mapView = GMSMapView.mapWithFrame(self.view.bounds, camera: camera)
        
        mapView.myLocationEnabled = true
        mapView.delegate = self
        
        baseView.addSubview(mapView)
        
        endSearchBar.hidden = true
        distanceLabel.hidden = true
        
        gasMileageClearButton.hidden = true
        gasPriceClearButton.hidden = true
        
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
                    self.currentLocationButtonBottomConstraint.constant = 14
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
                    self.currentLocationButtonBottomConstraint.constant = (14 + height - self.mainToolbarHeight.constant)
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
        if user.routeDistance != nil && user.gasMileage != nil && user.gasPrice != nil {
            calculateButton.hidden = false
            gasMileageToolbarButtonBottomConstraint.constant = 70
            gasPriceToolbarButtonBottomConstraint.constant = 70
            mainToolbarHeight.constant = gasMileageToolbarHeightConstant
            calculateButtonHeight.constant = 60
        }
    }
    
    func hideCalculateButton() {
        calculateButton.hidden = true
        gasMileageToolbarButtonBottomConstraint.constant = 10
        gasPriceToolbarButtonBottomConstraint.constant = 10
        mainToolbarHeight.constant = mainToolbarHeightConstant
    }
    
    //MARK: Finding Location

    func searchForLocation(searchText: String, searchingStartLocation: Bool) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let htmlString = searchText.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions(), range: Range<String.Index>(start: searchText.startIndex, end: searchText.endIndex))
        let params = "address=\(htmlString)&key=AIzaSyCqna5DDHzVmJBuBYwC3WELjmq8EbGTnAQ"
        let requestString = "https://maps.googleapis.com/maps/api/geocode/json?\(params)"
        
        Alamofire.request(.POST, requestString, parameters: nil).responseJSON(options: []) { (_, response, result) -> Void in
            hud.hide(true)
            
            if result.isSuccess {
                self.handleLocationSearchResponse(result.data!, searchingStartLocation: searchingStartLocation)
            }
            else {
                UIAlertView(title: "Sorry", message: "Network request failed, check your connection and try again", delegate: nil, cancelButtonTitle: "OK").show()
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
        }
    }
    
    func handleLocationSearchResponse(data: AnyObject, searchingStartLocation: Bool) {
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
                    startLocation = thoroughfare.joinWithSeparator(" ") + ", "
                }
                
                startLocation += location.joinWithSeparator(", ")
                
                startCoordinate.latitude = latitude!
                startCoordinate.longitude = longitude!
                
                startSearchBar.text = startLocation
                
                setMarker(coordinate: startCoordinate, searchingStartLocation: searchingStartLocation)
            }
            else {
                endLocation = ""
                
                if thoroughfare.count > 1 {
                    endLocation = thoroughfare.joinWithSeparator(" ") + ", "
                }
                
                endLocation += location.joinWithSeparator(", ")
                
                endCoordinate.latitude = latitude!
                endCoordinate.longitude = longitude!
                
                endSearchBar.text = endLocation
                
                setMarker(coordinate: endCoordinate, searchingStartLocation: searchingStartLocation)
            }
        }
    }
    
    //MARK: Calculating Distance
    
    func calculateDistance(origin origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let apiKey = "AIzaSyBQG_Le3xsE49W7dprNafDCgZ0vhdWIytw"
        let originParam = "origins=\(origin.latitude),\(origin.longitude)"
        let destinationParam = "destinations=\(destination.latitude),\(destination.longitude)"
        let requestString = "https://maps.googleapis.com/maps/api/distancematrix/json?\(originParam)&\(destinationParam)&units=imperial&key=\(apiKey)"
        
        Alamofire.request(.POST, requestString, parameters: nil).responseJSON(options: []) { (_, response, result) -> Void in
            hud.hide(true)
            
            if result.isSuccess {
                self.handleDistanceCalculationResponse(result.data!)
            }
            else {
                UIAlertView(title: "Sorry", message: "Network request failed, check your connection and try again", delegate: nil, cancelButtonTitle: "OK").show()
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
        }
    }
    
    func handleDistanceCalculationResponse(data: AnyObject) {
        let json = JSON(data)
        
        if let result = json["rows"][0]["elements"][0]["distance"]["text"].string {
            distanceLabel.text = " " + result + ". "
            
            let distanceLabelComponents = distanceLabel.text!.componentsSeparatedByString(" ")
            let routeDistanceString = distanceLabelComponents[1]
            let formattedString = NSString(string: routeDistanceString).stringByReplacingOccurrencesOfString(",", withString: "")
            user.routeDistance = NSString(string: formattedString).doubleValue
            
            if distanceLabelComponents[2] == "ft." {
                user.routeDistance! *= 0.000189
            }
            
            updateCalculateButton()
        }
        else {
            distanceLabel.text = "Could not find distance"
        }
        
        distanceLabel.hidden = false
    }
    
    //MARK: Map Methods
    
    func moveCameraBetweenPoints(coordinate1 coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) {
        let cameraUpdate = GMSCameraUpdate.fitBounds(GMSCoordinateBounds(coordinate: coordinate1, coordinate: coordinate2))
        
        mapView.animateWithCameraUpdate(cameraUpdate)
    }
    
    func setMarker(coordinate coordinate: CLLocationCoordinate2D, searchingStartLocation: Bool) {
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
    
    func reverseGeocode(coordinate coordinate: CLLocationCoordinate2D) {
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
            
            self.setMarker(coordinate: coordinate, searchingStartLocation: self.searchingStartLocation)
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
        requestString = requestString.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions(), range: Range<String.Index>(start: requestString.startIndex, end: requestString.endIndex))
        
        Alamofire.request(.GET, requestString, parameters: nil).responseJSON(options: []) { (_, response, result) -> Void in
            hud.hide(true)
            
            if result.isSuccess {
                self.handleSearchZipcodeResponse(result.data!)
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
        
        Alamofire.request(.GET, requestString, parameters: nil).responseString { (_, response, result) -> Void in
            hud.hide(true)
            
            if result.isSuccess {
                self.handleFindGasPriceResponse(result.data!)
            }
            else {
                self.gasPriceButton.setTitle("\(self.selectedLocation): Gas price could not be found", forState: UIControlState.Normal)
                
                self.hideGasPriceButtons()
            }
        }
    }
    
    func handleFindGasPriceResponse(data: AnyObject) {
        let html = data as! String
        
        if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
            var regPrices = [Double]()
            var plusPrices = [Double]()
            var prePrices = [Double]()
            
            var count = 0
            var numCells = 0
            
            for node in doc.css("td") {
                let contents = node.text!
                
                if !contents.isEmpty {
                    if numCells > 10 {
                        if contents[contents.startIndex] == "$" {
                            let startIndex = contents.startIndex.advancedBy(1)
                            let endIndex = contents.startIndex.advancedBy(6)
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
        else {
            UIAlertView(title: "Sorry", message: "Network request failed, check your connection and try again", delegate: nil, cancelButtonTitle: "OK").show()
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            self.gasPriceButton.setTitle("\(self.selectedLocation): Gas price could not be found", forState: UIControlState.Normal)
            hideGasPriceButtons()
        }
    }
    
    func showGasPriceButtons() {
        regularGasButton.hidden = false
        plusGasButton.hidden = false
        premiumGasButton.hidden = false
        
        plusGasButtonTopConstraint.constant = 10
        plusGasButtonBottomConstraint.constant = 10
        
        gasPriceToolbarHeight.constant = gasPriceToolbarHeightConstant
    }
    
    func hideGasPriceButtons() {
        regularGasButton.hidden = true
        plusGasButton.hidden = true
        premiumGasButton.hidden = true
        
        plusGasButtonTopConstraint.constant = -15
        plusGasButtonBottomConstraint.constant = -15
        
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
        gasPriceClearButton.hidden = false
    }
    
    //MARK: Navigation
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        if let identifier = segue.identifier {
            
            if identifier == "CarPickerDone" {
                let source = segue.sourceViewController as! CarPickerViewController
                
                gasMileageText = source.gasMileageText
                gasMileageButton.setTitle("\(gasMileageText) mi/gal", forState: UIControlState.Normal)
                
                gasMileageTextField.sizeToFit()
                
                gasMileageClearButton.hidden = false
                
                gasMileageTextField.enabled = false
            }
            else if identifier == "GasStationDone" {
                let source = segue.sourceViewController as! GasStationMapViewController
                
                selectedLocation = source.selectedLocation
                
                if source.zipcode != nil {
                    self.zipcode = source.zipcode!
                    findGasPrice()                    
                }
                else {
                    searchForZipcode()
                }
            }
            else if identifier == "StartOver" {
                mapView.camera = GMSCameraPosition.cameraWithLatitude(40, longitude: -100, zoom: 3)
                
                user = User()
                hideCalculateButton()
                hideGasPriceButtons()
                
                startCoordinate = CLLocationCoordinate2D()
                startLocation = ""
                endCoordinate = CLLocationCoordinate2D()
                endLocation = ""
                
                startMarker?.map = nil
                endMarker?.map = nil
                
                gasMileageTextField.text = ""
                gasMileageTextField.enabled = true
                gasMileageButton.setTitle("Don't know the gas mileage?", forState: UIControlState.Normal)
                gasMileageClearButton.hidden = true
                
                gasPriceTextField.text = ""
                gasPriceTextField.enabled = true
                gasPriceButton.setTitle("Don't know the gas price?", forState: UIControlState.Normal)
                gasPriceClearButton.hidden = true
                
                startSearchBar.text = ""
                endSearchBar.text = ""
                
                distanceLabel.hidden = true
                
                gasMileageToolbarButton.setTitle("Gas Mileage", forState: UIControlState.Normal)
                gasMileageToolbarButton.selected = false
                
                gasPriceToolbarButton.setTitle("Gas Price", forState: UIControlState.Normal)
                gasPriceToolbarButton.selected = false
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "ShowGasStationMap" {
                if !startLocation.isEmpty {
                    let gasStationMapViewController = segue.destinationViewController as! GasStationMapViewController
                    
                    gasStationMapViewController.defaultLocation = startLocation
                }
            }
            else if identifier == "ShowCalculation" {
                let calculationViewController = segue.destinationViewController as! CalculationViewController
                
                calculationViewController.routeDistance = user.routeDistance!
                calculationViewController.gasMileage = user.gasMileage!
                calculationViewController.gasPrice = user.gasPrice!
            }
        }
    }
    
}

extension MainViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.alpha = 1.0
        
        didChangeSearchBarText = true
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.alpha = 1.0
        
        searchingStartLocation = (searchBar === startSearchBar)
        
        if startSearchBar === searchBar || endSearchBar === searchBar {
            UIView.animateWithDuration(0.3) {
                self.gasMileageToolbarBottomConstraint.constant = 0
                self.gasPriceToolbarBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.alpha = 0.8
        
        if didChangeSearchBarText {
            if startSearchBar === searchBar {
                searchForLocation(startSearchBar.text!, searchingStartLocation: true)
            }
            else if endSearchBar === searchBar {
                searchForLocation(endSearchBar.text!, searchingStartLocation: false)
            }
        }
        
        didChangeSearchBarText = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchForLocation(searchBar.text!, searchingStartLocation: searchingStartLocation)
    }
    
}

extension MainViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.text!.rangeOfString(".") != nil {
            if textField === gasMileageTextField {
                if (string.rangeOfString(".") != nil || textField.text!.componentsSeparatedByString(".")[1].characters.count + string.characters.count > 1) {
                    return false
                }
            }
            else if textField === gasPriceTextField {
                if (string.rangeOfString(".") != nil || textField.text!.componentsSeparatedByString(".")[1].characters.count + string.characters.count > 2) {
                    return false
                }
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
