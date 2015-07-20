//
//  MapHelper.swift
//  GasShare
//
//  Created by Eric Kim on 7/20/15.
//  Copyright (c) 2015 Eric Kim. All rights reserved.
//

import GoogleMaps
import CoreLocation

class MapHelper {
    
    static func moveCamera(#mapView: GMSMapView, coordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 13, bearing: 0, viewingAngle: 0)
        let cameraUpdate = GMSCameraUpdate.setCamera(camera)
        
        mapView.animateWithCameraUpdate(cameraUpdate)
    }
    
}
