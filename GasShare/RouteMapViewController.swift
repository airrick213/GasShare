//
//  RouteMapViewController.swift
//  GasShare
//
//  Created by Eric Kim on 7/13/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit

import UIKit
import GoogleMaps
import CoreLocation

class RouteMapViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    let geoCoder = GMSGeocoder()
    var placesClient: GMSPlacesClient!
    var mapView: GMSMapView!
    var startCoordinate = CLLocationCoordinate2D()
    var startLocation = ""
    var endCoordinate = CLLocationCoordinate2D()
    var endLocation = ""
    var startMarker: GMSMarker?
    var endMarker: GMSMarker?
    var routeSearchViewController: RouteSearchViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //camera's coordinates are dummy values
        let camera = GMSCameraPosition.cameraWithLatitude(40, longitude: -100, zoom: 3)
        mapView = GMSMapView.mapWithFrame(self.view.bounds, camera: camera)
        
        mapView.myLocationEnabled = true
        mapView.settings.compassButton = true
        
        self.view = mapView
        
        routeSearchViewController = self.parentViewController as! RouteSearchViewController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func moveCamera(#coordinate: CLLocationCoordinate2D) {
        let cameraUpdate = GMSCameraUpdate.setTarget(coordinate, zoom: 13)
        
        mapView.animateWithCameraUpdate(cameraUpdate)
    }
    
    func moveCameraBetweenPoints(#coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) {
        let cameraUpdate = GMSCameraUpdate.fitBounds(GMSCoordinateBounds(coordinate: coordinate1, coordinate: coordinate2))
        
        mapView.animateWithCameraUpdate(cameraUpdate)
    }
    
    func setMarker(#coordinate: CLLocationCoordinate2D) {
        if routeSearchViewController.searchingStartLocation {
            startMarker = GMSMarker(position: coordinate)
            startMarker!.appearAnimation = kGMSMarkerAnimationPop
            
            startMarker!.title = self.startLocation
            
            startMarker!.map = mapView
        }
        else {
            endMarker = GMSMarker(position: coordinate)
            endMarker!.appearAnimation = kGMSMarkerAnimationPop
            
            endMarker!.title = self.endLocation
            
            endMarker!.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            
            endMarker!.map = mapView
        }
        
        if startMarker != nil && endMarker != nil {
            moveCameraBetweenPoints(coordinate1: startCoordinate, coordinate2: endCoordinate)
        }
        else if startMarker != nil {
            moveCamera(coordinate: startCoordinate)
        }
        else {
            moveCamera(coordinate: endCoordinate)
        }
    }
    
    func reverseGeocode(#coordinate: CLLocationCoordinate2D) {
        self.geoCoder.reverseGeocodeCoordinate(coordinate, completionHandler: { (result: GMSReverseGeocodeResponse?, error: NSError?) -> Void in
            if let address = result?.firstResult() {
                if self.routeSearchViewController.searchingStartLocation {
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
                    
                    self.routeSearchViewController.startSearchBar.text = self.startLocation
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
                    
                    self.routeSearchViewController.endSearchBar.text = self.endLocation
                }
            }
            
            self.setMarker(coordinate: coordinate)
        })
    }
    
}
