//
//  MapViewController.swift
//  GasShare
//
//  Created by Eric Kim on 7/6/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    let geoCoder = GMSGeocoder()
    var placesClient: GMSPlacesClient!
    var mapView: GMSMapView!
    var selectedCoordinate = CLLocationCoordinate2D()
    var selectedLocation = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //camera's coordinates are dummy values
        var camera = GMSCameraPosition.cameraWithLatitude(40, longitude: -100, zoom: 3)
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
    
    //reverse geocoding only needs to occur if the search bar wasn't used
    func setMarker(#coordinate: CLLocationCoordinate2D, usedSearchBar: Bool) {
        mapView.clear()
        
        self.selectedCoordinate = coordinate
        let marker = GMSMarker(position: coordinate)
        marker.appearAnimation = kGMSMarkerAnimationPop
        
        if usedSearchBar {
            marker.title = self.selectedLocation
        }
        else {
            self.geoCoder.reverseGeocodeCoordinate(coordinate, completionHandler: { (result: GMSReverseGeocodeResponse?, error: NSError?) -> Void in
                let address = result!.firstResult()
                self.selectedLocation = address.locality.capitalizedString + ", " + address.country.capitalizedString
                
                marker.title = self.selectedLocation
            })
        }
        
        marker.map = mapView
    }

}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        setMarker(coordinate: coordinate, usedSearchBar: false)
    }
    
}
