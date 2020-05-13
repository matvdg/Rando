//
//  LocationManager.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 03/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import CoreLocation


class LocationManager: NSObject, CLLocationManagerDelegate {
  
  static let shared = LocationManager()
  
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
}
