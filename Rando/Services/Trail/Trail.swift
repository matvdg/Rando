//
//  Trail.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 06/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import CoreLocation

struct Trail: Codable, Identifiable {
  
  // Decodable properties
  let id = UUID()
  var name: String
  var locations: [Location]
  
  // Computed properties
  var distance: String { "10km" }
  var positiveElevation: String { "1km" }
  var displayed: Bool { false }
  var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: 42.831111, longitude: 0.872026) }
  var elevations: [CLLocationDistance] {
    locations.map { $0.altitude }
  }
  
  mutating func rename(name: String) {
    self.name = name
  }
}


public struct Location: Codable {
  
  var latitude: CLLocationDegrees
  var longitude: CLLocationDegrees
  var altitude: CLLocationDistance
  
  init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, altitude: CLLocationDistance) {
    self.latitude = latitude
    self.longitude = longitude
    self.altitude = altitude
  }
  
  var clLocation: CLLocation {
    CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Location.self.CodingKeys.self)
    
    let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
    let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
    let altitude = try container.decode(CLLocationDistance.self, forKey: .altitude)
    
    self.init(latitude: latitude, longitude: longitude, altitude: altitude)
  }
}
