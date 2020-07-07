//
//  Trail.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 06/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import CoreLocation

let mockTrail = Trail(name: "Lac vert", locations: [])
let mockTrail2 = Trail(name: "Lac d'Ôo", locations: [])

struct Trail: Codable, Identifiable {
  
  // Decodable properties
  let id = UUID()
  var name: String
  var locations: [LocationWrapper]
  
  // Computed properties
  var distance: String { "10km" }
  var positiveElevation: String { "1km" }
  var displayed: Bool { true }
  var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: 42.831111, longitude: 0.872026) }
}

extension CLLocation: Encodable {
  public enum CodingKeys: String, CodingKey {
    case latitude
    case longitude
    case altitude
  }
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(coordinate.latitude, forKey: .latitude)
    try container.encode(coordinate.longitude, forKey: .longitude)
    try container.encode(altitude, forKey: .altitude)
  }
}

public struct LocationWrapper: Codable {
  
  var location: CLLocation
  
  init(location: CLLocation) {
    self.location = location
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CLLocation.CodingKeys.self)
    
    let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
    let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
    let altitude = try container.decode(CLLocationDistance.self, forKey: .altitude)
    
    let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
    
    self.init(location: location)
  }
}
