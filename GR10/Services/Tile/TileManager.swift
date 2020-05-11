
import Foundation
import MapKit

typealias TilesDownload = (numberOfTiles: Int, weightInMo: Float)

let template = "https://wxs.ign.fr/pratique/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.MAPS&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fjpeg&TileMatrix={z}&TileCol={x}&TileRow={y}"

typealias TileCoordinates = (x: Int, y: Int, z: Int)

class TileOverlay: MKTileOverlay {
  override func url(forTilePath path: MKTileOverlayPath) -> URL { TileManager.shared.getTileOverlay(for: path) }
}

class TileManager {
  
  static let shared = TileManager()
  
  init() {
    print("❤️ \(self.documentsDirectory)")
  }
  
  // MARK: -  Private properties
  private let userDefaults = UserDefaults.standard
  private let hasRecordedTilesKey = "hasRecordedTiles"
  private let isOfflineKey = "isOffline"
  private var overlay: MKTileOverlay { MKTileOverlay(urlTemplate: template) }
  
  private var documentsDirectory: URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  }
  
  // MARK: -  Public property
  var hasRecordedTiles: Bool {
    get {
      // Debug
//            false
      userDefaults.bool(forKey: hasRecordedTilesKey)
    }
    set {
      print("❤️ hasRecordedTiles = \(newValue)")
      userDefaults.set(newValue, forKey: hasRecordedTilesKey)
    }
  }
  
  var isOffline: Bool {
    get {
      // Debug
      //            false
      userDefaults.bool(forKey: isOfflineKey)
    }
    set {
      print("❤️ isOffline = \(newValue)")
      userDefaults.set(newValue, forKey: isOfflineKey)
    }
  }
  
  // MARK: -  Public methods
  func saveMock(completion: @escaping ( (Float) -> () )) {
    print("❤️ \(self.documentsDirectory)")
    var percent: Float = 0
    Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
      percent += 0.01
      completion(percent)
    }
  }
  
  func saveTilesAroundPolyline(completion: @escaping ( (Float) -> () )) {
    guard !hasRecordedTiles else { return }
    DispatchQueue.global(qos: .userInitiated).async {
      let locs =  GpxManager.shared.locations
      for (i, loc) in locs.enumerated() {
        guard i % 10 == 0 else { continue } // approximately take a gpx point every 100m
        if i % 100 == 0 {
          DispatchQueue.main.async {
            completion(Float(i) / Float(locs.count))
          }
        }
        let circle = MKCircle(center: loc, radius: 1000) // and draw a 1km circle around (low radius for highest zoom levels)
        let paths = self.computeTileOverlayPaths(boundingBox: circle.boundingMapRect)
        let filteredPaths = self.filterTilesAlreadyExisting(paths: paths)
        filteredPaths.forEach { self.persistLocally(path: $0) }
      }
      self.saveTilesAroundBoundingBox() // Larger radius for lowest zoom levels
      self.hasRecordedTiles = true
      DispatchQueue.main.async {
        NotificationManager.shared.sendNotification(title: "DownloadedTitle".localized, message: "DownloadedMessage".localized)
        completion(1)
      }
    }
  }
  
  func getTileOverlay(for path: MKTileOverlayPath) -> URL {
    //      print("❤️ \(path.z)")
    let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let url = documents.appendingPathComponent("z\(path.z)x\(path.x)y\(path.y).jpeg")
    if FileManager.default.fileExists(atPath: url.path) { // Check is tile is already available
      return url
    } else {
      if !isOffline { // Get and persist newTile
        return persistLocally(path: path)
      } else { // Else display empty tile (transparent over Maps tiles)
        return Bundle.main.url(forResource: "alpha", withExtension: "png")!
      }
    }
  }
  
  // MARK: -  Private methods
  private func saveTilesAroundBoundingBox() {
    let paths = self.computeTileOverlayPaths(boundingBox: GpxManager.shared.boundingBox, maxZ: 8)
    let filteredPaths = self.filterTilesAlreadyExisting(paths: paths)
    filteredPaths.forEach { self.persistLocally(path: $0) }
  }
  
  private func computeTileOverlayPaths(boundingBox box: MKMapRect, maxZ: Int = 16) -> [MKTileOverlayPath] {
    var paths = [MKTileOverlayPath]()
    for z in 1...maxZ {
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
  
  @discardableResult private func persistLocally(path: MKTileOverlayPath) -> URL {
    let url = overlay.url(forTilePath: path)
    let file = "z\(path.z)x\(path.x)y\(path.y).jpeg"
    let filename = self.documentsDirectory.appendingPathComponent(file)
    do {
      let data = try Data(contentsOf: url)
      try data.write(to: filename)
    } catch {
      print("❤️ \(error)")
    }
    return url
  }
  
  private func filterTilesAlreadyExisting(paths: [MKTileOverlayPath]) -> [MKTileOverlayPath] {
    return paths.filter {
      let path = self.documentsDirectory.appendingPathComponent("z\($0.z)x\($0.x)y\($0.y).jpeg").path
      return !FileManager.default.fileExists(atPath: path)
    }
  }
  
}
