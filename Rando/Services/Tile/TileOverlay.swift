//
//  TileOverlay.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 15/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import MapKit

typealias TileCoordinates = (x: Int, y: Int, z: Int)

class IGNV2Overlay: MKTileOverlay {
    override func url(forTilePath path: MKTileOverlayPath) -> URL { TileManager.shared.getTileOverlay(for: path, layer: .ign) }
}

class IGN25Overlay: MKTileOverlay {
    override func url(forTilePath path: MKTileOverlayPath) -> URL { TileManager.shared.getTileOverlay(for: path, layer: .ign25) }
}

class OpenTopoMapOverlay: MKTileOverlay {
    override func url(forTilePath path: MKTileOverlayPath) -> URL { TileManager.shared.getTileOverlay(for: path, layer: .openTopoMap) }
}

class OpenStreetMapOverlay: MKTileOverlay {
    override func url(forTilePath path: MKTileOverlayPath) -> URL { TileManager.shared.getTileOverlay(for: path, layer: .openStreetMap) }
}

//class SwissTopoOverlay: MKTileOverlay {
//    override func url(forTilePath path: MKTileOverlayPath) -> URL { TileManager.shared.getTileOverlay(for: path, layer: .swissTopo) }
//}
