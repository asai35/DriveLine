//
//  LocationManager.swift
//  DriveLine
//
//  Created by mac on 8/17/17.
//  Copyright © 2017 Abdul Wahib. All rights reserved.
//

import UIKit

import CoreLocation

class LocationManager : CLLocationManager {

    static var sharedInstance = LocationManager()

    var currentLocation : CLLocationCoordinate2D?

    var locationDelegate : LocationManagerProtocol?

    fileprivate override init() {
        super.init()

        self.delegate = self
        self.desiredAccuracy = kCLLocationAccuracyBest
        self.requestWhenInUseAuthorization()
    }
}

extension LocationManager : CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        currentLocation = manager.location!.coordinate
        // print_debug("locations = \(currentLocation!.latitude) \(currentLocation!.longitude)")

        if locationDelegate != nil {

            locationDelegate?.didUpdateLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

        currentLocation = nil

        //        PopUpAlert.showNoLocationAlert()
    }
}

func isLocationEnabled () -> Bool {

    if CLLocationManager.locationServicesEnabled() {

        switch(CLLocationManager.authorizationStatus()) {

        case .notDetermined, .restricted, .denied:
            return false

        case .authorizedAlways, .authorizedWhenInUse:
            return true
        }
    } else {

        return false
    }
}
