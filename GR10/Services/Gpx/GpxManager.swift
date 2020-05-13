//
//  GpxManager.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class GpxManager {
  
  static let shared = GpxManager()
  
  var locations = [CLLocationCoordinate2D]()
  
  lazy var polyline = MKPolyline(coordinates: locations, count: locations.count)
  lazy var boundingBox = polyline.boundingMapRect
  
  init() {
    locations = getLocations()
  }
  
  // MARK: - Public method
  func distanceTo(to poi: CLLocationCoordinate2D) -> String {
    
    let date = Date()
    
    let minDistanceToUser = minimumDistanceToPolyline(from: LocationManager.shared.currentPosition.coordinate)
    let minDistanceToPoi = minimumDistanceToPolyline(from: poi)
        
    var totalDistance: CLLocationDistance = minDistanceToUser.distance + minDistanceToPoi.distance
    
    let indexes = [minDistanceToUser.index, minDistanceToPoi.index].sorted { $0 < $1 }
        
    for i in indexes[0]..<indexes[1] {
      totalDistance += locations[i].distance(from: locations[i+1])
    }
    
    print("❤️ Elapsed time to compute polyline distance = \(Date().timeIntervalSince(date))s")
    
    return totalDistance.toString
  }
  
  // MARK: - Private methods
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
  
  private func minimumDistanceToPolyline(from coordinate: CLLocationCoordinate2D) -> (distance: CLLocationDistance, index: Int) {
    var index = 0
    var minDistance: CLLocationDistance = .infinity
    
    for (i, loc) in locations.enumerated() {
      let distance = loc.distance(from: coordinate)
      guard distance < minDistance else { continue }
      minDistance = distance
      index = i
    }
    
    return (minDistance, index)
  }
  
}
