//
//  PoiManager.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class PoiManager {
  
  static let shared = PoiManager()
  
  var pois = [Poi]()
  var annotations: [PoiAnnotation] {
    pois.map { PoiAnnotation(poi: $0) }
  }
  
  init() {
    pois = getPois()
  }
  
  private func getPois() -> [Poi] {
    let url = Bundle.main.url(forResource: "pois", withExtension: "json")!
    do {
      let data = try Data(contentsOf: url)
      let pois = try JSONDecoder().decode([Poi].self, from: data)
      print("❤️ pois = \(pois.count)")
      return pois
    } catch {
      switch error {
      case DecodingError.keyNotFound(let key, let context): print("❤️ error = \(error.localizedDescription), key not found = \(key), context = \(context)")
      default: print("❤️ error = \(error.localizedDescription)")
      }
      return []
    }
  }
  
}

class PoiAnnotation: MKPointAnnotation {
 
  var poi: Poi
  
  init(poi: Poi) {
    self.poi = poi
    super.init()
    self.coordinate = CLLocationCoordinate2D(latitude: poi.lat, longitude: poi.lng)
    self.title = poi.name
    self.subtitle = "Altitude \(Int(poi.alt))m, Km \(poi.dist)"
  }
  
}
