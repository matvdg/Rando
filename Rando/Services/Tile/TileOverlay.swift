//
//  TileOverlay.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 15/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import MapKit

let template =

"https://wxs.ign.fr/pratique/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.PLANIGNV2&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fpng&TileMatrix={z}&TileCol={x}&TileRow={y}"

typealias TileCoordinates = (x: Int, y: Int, z: Int)

class TileOverlay: MKTileOverlay {
    override func url(forTilePath path: MKTileOverlayPath) -> URL { TileManager.shared.getTileOverlay(for: path) }
}
