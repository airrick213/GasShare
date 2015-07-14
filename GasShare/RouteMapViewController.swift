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
    var firstLocation = true
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
            let camera = GMSCameraPosition.cameraWithLatitude(coordinate.latitude, longitude: coordinate.longitude, zoom: 13)
            mapView.camera = camera
        }
    }
    
    func setMarker(#searchingStartLocation: Bool) {
        makeMarker(searchingStartLocation: searchingStartLocation)
    }
    
    func makeMarker(#searchingStartLocation: Bool) {
        let coordinate = mapView.camera.target
        
        if searchingStartLocation {
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
    }
    
}

extension RouteMapViewController: GMSMapViewDelegate {
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        moveCamera(coordinate: coordinate)
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        firstLocation = false
    }
    
}
