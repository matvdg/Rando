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
  
  init() {
    pois = getPois()
  }
  
  private func getPois() -> [Poi] {
    let url = Bundle.main.url(forResource: "pois", withExtension: "json")!
    do {
      let data = try Data(contentsOf: url)
      let pois = try JSONDecoder().decode([Poi].self, from: data)
      print("❤️ Pois = \(pois.count)")
      return pois
    } catch {
      switch error {
      case DecodingError.keyNotFound(let key, let context): print("❤️ Error = \(error.localizedDescription), key not found = \(key), context = \(context)")
      default: print("❤️ Error = \(error.localizedDescription)")
      }
      return []
    }
  }
  
}

class PoiAnnotation: MKPointAnnotation {
  
  var poi: Poi
  
  var markerColor: UIColor {
    switch poi.category {
    case .refuge: return .gred
    case .spring, .waterfall, .lake, .bridge: return .grblue
    case .peak, .pov, .pass, .camping : return .grgreen
    default: return .grgray
    }
  }
  
  var markerGlyph: UIImage {
    switch poi.category {
    case .refuge: return UIImage(systemName: "house.fill")!
    case .waterfall: return UIImage(systemName: "camera.fill")!
    case .peak, .pov, .pass, .lake: return UIImage(systemName: "eye.fill")!
    case .parking: return UIImage(systemName: "car.fill")!
    case .camping: return UIImage(systemName: "flame.fill")!
    default: return UIImage(systemName: "mappin")!
    }
  }
  
  init(poi: Poi) {
    self.poi = poi
    super.init()
    self.coordinate = CLLocationCoordinate2D(latitude: poi.lat, longitude: poi.lng)
  }
  
}
