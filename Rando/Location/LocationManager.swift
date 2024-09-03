//
//  LocationManager.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 03/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import CoreLocation

protocol HeadingDelegate {
    func didUpdate(_ heading: CLLocationDirection)
}


class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    var userHeading: CLLocationDirection?
    var headingDelegate: HeadingDelegate?
    var updateHeading: Bool = false {
        willSet {
            if newValue {
                manager.startUpdatingHeading()
            } else {
                manager.stopUpdatingHeading()
            }
        }
    }
    
    override init() {
        super.init()
        requestAuthorization()
    }
    
    var currentPosition = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 42.835191, longitude: 0.872005), altitude: 1944, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date()) // Etang d'Araing
    
    let manager = CLLocationManager()
    
    func requestAuthorization() {
        manager.activityType = .fitness
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        currentPosition = loc
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy < 0 { return }
        let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        self.headingDelegate?.didUpdate(heading)
    }
    
    func getDepartment(location: CLLocation, completion: @escaping (String?)->()) {
        let geocoder = CLGeocoder()
        geocoder.getDepartment(from: location) { department in
            completion(department)
        }
    }
}
