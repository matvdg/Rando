//
//  Poi.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import UIKit
import CoreLocation

struct Poi: Decodable, Identifiable {
  
  // Computed properties
  var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: lat, longitude: lng) }
  var altitudeInMeters: String { "\(Int(alt))m" }
  var distanceInKilometers: String { "\(Int(dist))" } // Hendaye to Banyuls
  var distanceInKilometersInverted: String { "\(Int(922 - dist))" } // Banyuls to Hendaye
  var url: URL? {
    guard let website = website else { return nil }
    return URL(string: "http://\(website)")
  }
  var phoneNumber: URL? {
    guard let number = phone else { return nil }
    let cleaned = number.components(separatedBy: " ").joined()
    return URL(string: "tel://\(cleaned)")
  }
  var hasWebsite: Bool { url != nil }
  var hasPhoneNumber: Bool { phoneNumber != nil }
  
  var distanceFromUser: String {
    let alongPolylineDistance = GpxManager.shared.distanceTo(to: self.coordinate)
    let straightDistance = LocationManager.shared.currentPosition.coordinate.distance(from: self.coordinate).toString
    print("❤️ AlongPolylineDistance = \(alongPolylineDistance) VS StraightDistance = \(straightDistance)")
    return alongPolylineDistance
  }

  // Decodable properties
  var id: Int
  var name: String
  var category: Category
  var lat: CLLocationDegrees
  var lng: CLLocationDegrees
  var alt: CLLocationDistance
  var dist: CLLocationDistance
  // Optional
  var phone: String?
  var description: String?
  var website: String?
  
  
  enum Category: String, Decodable, CaseIterable {
    case refuge, waterfall, spring, step, peak, pov, pass, parking, lake, dam, camping, bridge
  }
}
