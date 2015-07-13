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
    var selectedCoordinate = CLLocationCoordinate2D()
    var selectedLocation = ""
    var firstLocation = true
    var usedSearchBar = false
    
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
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        
        self.view = mapView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func moveCamera(#coordinate: CLLocationCoordinate2D) {
        if !firstLocation {
            let camera = GMSCameraPosition.cameraWithLatitude(coordinate.latitude, longitude: coordinate.longitude, zoom: 12)
            mapView.camera = camera
        }
    }
    
    func setMarker(#coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        
        self.selectedCoordinate = coordinate
        let marker = GMSMarker(position: coordinate)
        marker.appearAnimation = kGMSMarkerAnimationPop
        
        marker.title = self.selectedLocation
        
        marker.map = mapView
        
        if !usedSearchBar {
            reverseGeocode(coordinate: coordinate)
        }
        else {
            usedSearchBar = false
        }
    }
    
    func reverseGeocode(#coordinate: CLLocationCoordinate2D) {
        self.geoCoder.reverseGeocodeCoordinate(coordinate, completionHandler: { (result: GMSReverseGeocodeResponse?, error: NSError?) -> Void in
            if let address = result?.firstResult() {
                self.selectedLocation = ""
                
                if let thoroughfare = address.thoroughfare {
                    self.selectedLocation = thoroughfare
                }
                
                if let locality = address.locality {
                    if !self.selectedLocation.isEmpty {
                        self.selectedLocation += ", "
                    }
                    
                    self.selectedLocation += locality.capitalizedString
                }
                
                if let administrativeArea = address.administrativeArea {
                    if !self.selectedLocation.isEmpty {
                        self.selectedLocation += ", "
                    }
                    
                    self.selectedLocation += administrativeArea.capitalizedString
                }
            }
            
            let marker = GMSMarker(position: coordinate)
            marker.title = self.selectedLocation
            marker.map = self.mapView
        })
    }
    
}

extension RouteMapViewController: GMSMapViewDelegate {
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        moveCamera(coordinate: coordinate)
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
