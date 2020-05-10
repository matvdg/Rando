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
  
  let manager = CLLocationManager()
  
  
  func request() {
    self.manager.activityType = .fitness
    self.manager.requestWhenInUseAuthorization()
    self.manager.delegate = self
    self.manager.startUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    self.manager.startUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let loc = locations.first else { return }
    coordinate = loc.coordinate
  }
}
