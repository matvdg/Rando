//
//  GpxRepository.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class GpxRepository {
  
  static let shared = GpxRepository()
  
  var locations = [CLLocationCoordinate2D]()
  var polyline: MKPolyline {
    MKPolyline(coordinates: locations, count: locations.count)
  }
  
  init() {
    locations = getLocations()
  }
  
  private func getLocations() -> [CLLocationCoordinate2D] {
    let filepath = Bundle.main.path(forResource: "gr10", ofType: "gpx")!
    let contents = try! String(contentsOfFile: filepath, encoding: .utf8)
    let lines = contents.components(separatedBy: "\n")
    let locations =  lines.compactMap { line -> CLLocationCoordinate2D? in
      let result = line.components(separatedBy: "\"").compactMap { Double($0) }
      guard result.count == 2, let lat = result.first, let lng = result.last else { return nil }
      return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    return locations
  }
  
  
  
}
