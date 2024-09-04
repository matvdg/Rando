//
//  PoiManager.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class PoiManager {
  
  static let shared = PoiManager()
  
  var pois = [Poi]()
  
  init() {
    pois = getPois()
  }
  
  private func getPois() -> [Poi] {
    let url = Bundle.main.url(forResource: "pois", withExtension: "json")!
    do {
      let data = try Data(contentsOf: url)
      let pois = try JSONDecoder().decode([Poi].self, from: data)
      print("􀎫 Pois = \(pois.count)")
      return pois
    } catch {
      switch error {
      case DecodingError.keyNotFound(let key, let context): print("􀎫 Decoding pois error = \(error.localizedDescription), key not found = \(key), context = \(context)")
      default: print("􀎫 Decoding pois error = \(error.localizedDescription)")
      }
      return []
    }
  }
  
}

class PoiAnnotation: MKPointAnnotation {
  
  var poi: Poi
  
  var markerColor: UIColor {
    switch poi.category {
    case .spring, .waterfall, .lake, .bridge: return .grblue
    case .peak, .pov, .pass : return .grgreen
    case .refuge, .camping, .shelter: return .systemBlue
    case .shop: return .grpink
    default: return .grgray
    }
  }
  
  init(poi: Poi) {
    self.poi = poi
    super.init()
    self.coordinate = CLLocationCoordinate2D(latitude: poi.lat, longitude: poi.lng)
  }
  
}
