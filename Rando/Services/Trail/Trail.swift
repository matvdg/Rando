//
//  Trail.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 06/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import CoreLocation

let mockTrail = Trail(id: 69, name: "Lac vert", lat: 42.637848, lng: 1.725750, displayed: true)
let mockTrail2 = Trail(id: 70, name: "Lac d'Ôo", lat: 42.637848, lng: 1.725750, displayed: false)

struct Trail: Decodable, Identifiable {
  
  // Decodable properties
  var id: Int
  var name: String
  var lat: CLLocationDegrees
  var lng: CLLocationDegrees
  var displayed: Bool
  
  // Computed properties
  var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: lat, longitude: lng) }
  var distance: String { "10km" }
  var positiveElevation: String { "1km" }
}
