//
//  Poi.swift
//  Rando
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
  var distanceInKilometers: String { "KM \(Int(dist))" } // Hendaye to Banyuls
  var distanceInKilometersInverted: String { "KM \(Int(922 - dist))" } // Banyuls to Hendaye
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
  
  var estimations: Estimations {
    let estimations = TrailManager.shared.estimations(for: self)
    let straightDistance = LocationManager.shared.currentPosition.coordinate.distance(from: self.coordinate).toString
    print("❤️ AlongPolylineDistance = \(estimations.distance) VS StraightDistance = \(straightDistance)")
    return estimations
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
  
  init(lat: CLLocationDegrees, lng: CLLocationDegrees, alt: CLLocationDistance) {
    self.id = 0
    self.name = "Pin".localized
    self.category = .step
    self.lat = lat
    self.lng = lng
    self.alt = alt
    self.dist = 0
  }
  
  
  enum Category: String, Decodable, CaseIterable {
    case refuge, waterfall, spring, step, peak, pov, pass, parking, lake, dam, camping, bridge
  }
}
