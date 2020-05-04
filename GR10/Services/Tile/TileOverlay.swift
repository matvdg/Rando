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
    if let url = Bundle.main.url(forResource: "z\(path.z)x\(path.x)y\(path.y)", withExtension: "jpeg") {
      return url
    } else {
      return Bundle.main.url(forResource: "empty", withExtension: "jpeg")!
    }
  }
  
}
