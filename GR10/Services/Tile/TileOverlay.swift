//
//  TileOverlay.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import MapKit
typealias TileCoordinates = (x: Int, y: Int, z: Int)


class TileOverlay: MKTileOverlay {
  override func url(forTilePath path: MKTileOverlayPath) -> URL {
    let userDefaults = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let url = userDefaults.appendingPathComponent("z\(path.z)x\(path.x)y\(path.y).jpeg")
    if FileManager.default.fileExists(atPath: url.path) {
      return url
    } else {
//      print("❤️ \(path.z)")
      return Bundle.main.url(forResource: "alpha", withExtension: "png")!
    }
  }
}
