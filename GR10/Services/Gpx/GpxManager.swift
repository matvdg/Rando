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

typealias Estimations = (distance: String, positiveElevation: String, negativeElevation: String, duration: String)

class GpxManager {
  
  static let shared = GpxManager()
  
  var locations = [CLLocation]()
  var locationsCoordinate: [CLLocationCoordinate2D] { locations.map { $0.coordinate } }
  
  lazy var polyline = MKPolyline(coordinates: locationsCoordinate, count: locations.count)
  lazy var boundingBox = polyline.boundingMapRect
  
  init() {
    locations = getLocations()
  }
  
  // MARK: - Public method
  func estimations(for poi: Poi) -> Estimations {
    
    let date = Date()
    
    let minDistanceToUser = minimumDistanceToPolyline(from: LocationManager.shared.currentPosition.coordinate)
    let minDistanceToPoi = minimumDistanceToPolyline(from: poi.coordinate)
        
    var distance: CLLocationDistance = minDistanceToUser.distance + minDistanceToPoi.distance
    var positiveElevation: CLLocationDistance = 0
    var negativeElevation: CLLocationDistance = 0
    
    let indexes = [minDistanceToUser.index, minDistanceToPoi.index].sorted { $0 < $1 }
        
    for i in indexes[0]..<indexes[1] {
      distance += locations[i].distance(from: locations[i+1])
      let elevation = locations[i+1].altitude - locations[i].altitude
      if elevation > 0 {
        positiveElevation += elevation
      } else {
        negativeElevation += elevation
      }
    }
    
    // Add elevation to POI (usefull if the POI is outside the GR10 polyline like a summit)
    let elevation = poi.alt - locations[minDistanceToPoi.index].altitude
    if elevation > 0 {
      positiveElevation += elevation
    } else {
      negativeElevation += elevation
    }
    // At the contrary we don't add elevation from the user if he is outside the GR10 polyline as the elevation from the GPS is not accurate, particularly in mountains and if the user is far away from the GR10 (at home, looking at the app for example from Toulouse, so the elevation added would have been irrelevant)
    
    print("❤️ Elapsed time to compute polyline distance & elevation = \(Date().timeIntervalSince(date))s")
    let duration = getDurationEstimation(distance: distance, positiveElevation: positiveElevation)
    return (distance.toString, positiveElevation.toString, abs(negativeElevation).toString, duration)
  }
  
  // MARK: - Private methods
  private func getLocations() -> [CLLocation] {
    let filepath = Bundle.main.path(forResource: "gr10", ofType: "gpx")!
    let contents = try! String(contentsOfFile: filepath, encoding: .utf8)
    let lines = contents.components(separatedBy: "\n")
    let locations =  lines.compactMap { line -> CLLocation? in
      let result = line.components(separatedBy: "\"").compactMap { Double($0) }
      guard result.count == 3 else { return nil }
      let lat = result[0]
      let lng = result[1]
      let ele = result[2]
      return CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng), altitude: ele, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
    }
    return locations
  }
  
  private func minimumDistanceToPolyline(from coordinate: CLLocationCoordinate2D) -> (distance: CLLocationDistance, index: Int) {
    var index = 0
    var minDistance: CLLocationDistance = .infinity
    
    for (i, loc) in locationsCoordinate.enumerated() {
      let distance = loc.distance(from: coordinate)
      guard distance < minDistance else { continue }
      minDistance = distance
      index = i
    }
    
    return (minDistance, index)
  }
  
  private func getDurationEstimation(distance: CLLocationDistance, positiveElevation: CLLocationDistance) -> String {
    let speed: CLLocationSpeed = 1.111 // 4Km.h-1
    let totalDistance = distance + 10 * positiveElevation
    let duration = totalDistance/speed
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute]
    formatter.unitsStyle = .abbreviated
    return formatter.string(from: duration) ?? ""
  }
  
}
