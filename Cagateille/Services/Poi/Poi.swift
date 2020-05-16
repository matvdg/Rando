//
//  Poi.swift
//  Cagateille
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
  
  var estimations: Estimations {
    let estimations = GpxManager.shared.estimations(for: self)
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
  // Optional
  var description: String?
  
  
  enum Category: String, Decodable, CaseIterable {
    case refuge, waterfall, spring, step, peak, pov, pass, parking, lake, dam, camping, bridge
  }
}
