
import Foundation
import MapKit

typealias TilesDownload = (numberOfTiles: Int, weightInMo: Float)


class TileManager {
  
  private let minZLevel = 14
  private let maxZLevel = 16
  
  private let template = "https://wxs.ign.fr/pratique/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.MAPS&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fjpeg&TileMatrix={z}&TileCol={x}&TileRow={y}"
  
  
  private var documentsDirectory: URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  }
  
  func saveTilesAroundPolyline() {
    print(self.documentsDirectory)
    let locs =  GpxRepository().load()
    for (i, loc) in locs.enumerated() {
      guard i % 100 == 0 else { continue }
      print("\(Int(Double(i) / Double(locs.count) * 100))%")
      let circle = MKCircle(center: loc, radius: 1000)
      let paths = self.computeTileOverlayPaths(boundingBox: circle.boundingMapRect)
      let filteredPaths = self.filterTilesAlreadyExisting(paths: paths)
      let overlay = MKTileOverlay(urlTemplate: self.template)
      for path in filteredPaths {
        let url = overlay.url(forTilePath: path)
        let file = "z\(path.z)x\(path.x)y\(path.y).jpeg"
        self.persistLocally(url: url, to: file)
      }
    }
  }
  
  
  
  func saveTiles(boundingBox: MKMapRect, completion: @escaping ( (Float) -> () ) ) {
    DispatchQueue.global(qos: .userInitiated).async {
      
      let paths = self.computeTileOverlayPaths(boundingBox: boundingBox)
      let filteredPaths = self.filterTilesAlreadyExisting(paths: paths)
      let overlay = MKTileOverlay(urlTemplate: self.template)
      let count = Float(filteredPaths.count)
      for (index, path) in filteredPaths.enumerated() {
        let url = overlay.url(forTilePath: path)
        let file = "z\(path.z)x\(path.x)y\(path.y).jpeg"
        self.persistLocally(url: url, to: file)
        DispatchQueue.main.async {
          let percent = Float(index + 1) / count * 100
          print("Downloaded \(index+1)/\(count), \(Int(percent))%")
          completion(percent)
        }
      }
    }
  }
  
  private func computeTileOverlayPaths(boundingBox box: MKMapRect) -> [MKTileOverlayPath] {
    var paths = [MKTileOverlayPath]()
    for z in self.minZLevel...self.maxZLevel {
      let topLeft = self.tranformCoordinate(coordinates: MKMapPoint(x: box.minX, y: box.minY).coordinate, zoom: z)
      let topRight = self.tranformCoordinate(coordinates: MKMapPoint(x: box.maxX, y: box.minY).coordinate, zoom: z)
      let bottomLeft = self.tranformCoordinate(coordinates: MKMapPoint(x: box.minX, y: box.maxY).coordinate, zoom: z)
      for x in topLeft.x...topRight.x {
        for y in topLeft.y...bottomLeft.y {
          paths.append(MKTileOverlayPath(x: x, y: y, z: z, contentScaleFactor: 2))
        }
      }
    }
    return paths
  }
  
  private func tranformCoordinate(coordinates: CLLocationCoordinate2D , zoom: Int) -> TileCoordinates {
    let lng = coordinates.longitude
    let lat = coordinates.latitude
    let tileX = Int(floor((lng + 180) / 360.0 * pow(2.0, Double(zoom))))
    let tileY = Int(floor((1 - log( tan( lat * Double.pi / 180.0 ) + 1 / cos( lat * Double.pi / 180.0 )) / Double.pi ) / 2 * pow(2.0, Double(zoom))))
    return (tileX, tileY, zoom)
  }
  
  // MARK: -  Private methods
  private func persistLocally(url: URL, to pathComponent: String) {
    let filename = self.documentsDirectory.appendingPathComponent(pathComponent)
    guard let data = try? Data(contentsOf: url) else { return }
    do {
      try data.write(to: filename)
    } catch {
      print(error)
    }
  }
  
  private func filterTilesAlreadyExisting(paths: [MKTileOverlayPath]) -> [MKTileOverlayPath] {
    return paths.filter {
      let path = self.documentsDirectory.appendingPathComponent("z\($0.z)x\($0.x)y\($0.y).jpeg").path
      return !FileManager.default.fileExists(atPath: path)
    }
  }
  
}
