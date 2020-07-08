
import Foundation
import MapKit

typealias TilesDownload = (numberOfTiles: Int, weightInMo: Float)

enum Directory: String, CaseIterable {
  case cache, rando, trails
  var localized: String { rawValue.localized }
  var state: State {
    switch self {
    case .cache, .trails: return .downloaded
    case .rando:
      if TileManager.shared.hasRecordedTiles {
        return .downloaded
      } else {
        return TileManager.shared.progress == 0 ? .empty : .downloading
      }
    }
  }
  enum State {
    case downloaded, downloading, empty
  }
}

let template = "https://wxs.ign.fr/pratique/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.MAPS&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fjpeg&TileMatrix={z}&TileCol={x}&TileRow={y}"

typealias TileCoordinates = (x: Int, y: Int, z: Int)

class TileOverlay: MKTileOverlay {
  override func url(forTilePath path: MKTileOverlayPath) -> URL { TileManager.shared.getTileOverlay(for: path) }
}

class TileManager: ObservableObject {
  
  static let shared = TileManager()
  
  init() {
    print("❤️ DocumentsDirectory = \(documentsDirectory)")
    createDirectoriesIfNecessary()
  }
  
  // MARK: -  Private properties
  private let userDefaults = UserDefaults.standard
  private let hasRecordedTilesKey = "hasRecordedTiles"
  private let isOfflineKey = "isOffline"
  private var overlay: MKTileOverlay { MKTileOverlay(urlTemplate: template) }
  
  private var documentsDirectory: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! }
  
  // MARK: -  Public property
  var hasRecordedTiles: Bool {
    get {
      userDefaults.bool(forKey: hasRecordedTilesKey)
    }
    set {
      print("❤️ HasRecordedTiles = \(newValue)")
      userDefaults.set(newValue, forKey: hasRecordedTilesKey)
    }
  }
  
  var isOffline: Bool {
    get {
      userDefaults.bool(forKey: isOfflineKey)
    }
    set {
      print("❤️ IsOffline = \(newValue)")
      userDefaults.set(newValue, forKey: isOfflineKey)
    }
  }
  
  @Published var progress: Float = 0
  
  // MARK: -  Public methods
  func getSize(of directory: Directory) -> String {
    FileManager.default.allocatedSizeOfDirectory(at: documentsDirectory.appendingPathComponent(directory.rawValue))
  }
  
  func remove(directory: Directory) {
    try? FileManager.default.removeItem(at: documentsDirectory.appendingPathComponent(directory.rawValue))
    createDirectoriesIfNecessary()
    if directory == .rando { self.hasRecordedTiles = false }
  }
  
  func saveMock(completion: @escaping ( (Float) -> () )) {
    var percent: Float = 0
    Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
      percent += 0.01
      completion(percent)
    }
  }
    
  /// Download and save to cache all tiles around the polyline
  func startDownload() {
    guard !hasRecordedTiles else { return }
    progress = 0.01
    DispatchQueue.global(qos: .background).async {
      let locs =  TrailManager.shared.currentLocationsCoordinate // Average one loc per 60 meters
      for (i, loc) in locs.enumerated() {
        guard i % 10 == 0 else { continue } // approximately take a gpx point every 600m
        if i % 100 == 0 { self.progress =  Float(i) / Float(locs.count) }
        let circle = MKCircle(center: loc, radius: 1000) // and draw a 1km circle around (low radius for highest zoom levels)
        let paths = self.computeTileOverlayPaths(boundingBox: circle.boundingMapRect)
        let filteredPaths = self.filterTilesAlreadyExisting(paths: paths)
        filteredPaths.forEach { self.persistLocally(path: $0) }
      }
      self.saveTilesAroundBoundingBox() // Larger radius for lowest zoom levels
      DispatchQueue.main.async {
        NotificationManager.shared.sendNotification(title: "DownloadedTitle".localized, message: "DownloadedMessage".localized)
        self.hasRecordedTiles = true
        self.progress = 0
      }
    }
  }
  
  func getTileOverlay(for path: MKTileOverlayPath) -> URL {
    let file = "z\(path.z)x\(path.x)y\(path.y).jpeg"
    // Check is tile is already available
    let grUrl = documentsDirectory.appendingPathComponent(Directory.rando.rawValue).appendingPathComponent(file)
    let cacheUrl = documentsDirectory.appendingPathComponent(Directory.cache.rawValue).appendingPathComponent(file)
    if FileManager.default.fileExists(atPath: grUrl.path) {
      return grUrl
    } else if FileManager.default.fileExists(atPath: cacheUrl.path){
      return cacheUrl
    } else {
      if !isOffline { // Get and persist newTile
        return persistLocally(path: path, directory: .cache)
      } else { // Else display empty tile (transparent over Maps tiles)
        return Bundle.main.url(forResource: "alpha", withExtension: "png")!
      }
    }
  }
  
  // MARK: -  Private methods
  private func saveTilesAroundBoundingBox() {
    let paths = computeTileOverlayPaths(boundingBox: TrailManager.shared.boundingBox, maxZ: 8)
    let filteredPaths = filterTilesAlreadyExisting(paths: paths)
    filteredPaths.forEach { persistLocally(path: $0) }
  }
  
  private func computeTileOverlayPaths(boundingBox box: MKMapRect, maxZ: Int = 16) -> [MKTileOverlayPath] {
    var paths = [MKTileOverlayPath]()
    for z in 1...maxZ {
      let topLeft = tranformCoordinate(coordinates: MKMapPoint(x: box.minX, y: box.minY).coordinate, zoom: z)
      let topRight = tranformCoordinate(coordinates: MKMapPoint(x: box.maxX, y: box.minY).coordinate, zoom: z)
      let bottomLeft = tranformCoordinate(coordinates: MKMapPoint(x: box.minX, y: box.maxY).coordinate, zoom: z)
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
  
  @discardableResult private func persistLocally(path: MKTileOverlayPath, directory: Directory = .rando) -> URL {
    let url = overlay.url(forTilePath: path)
    let file = "\(directory)/z\(path.z)x\(path.x)y\(path.y).jpeg"
    let filename = documentsDirectory.appendingPathComponent(file)
    do {
      let data = try Data(contentsOf: url)
      try data.write(to: filename)
    } catch {
      print("❤️ PersistLocallyError = \(error)")
    }
    return url
  }
  
  private func filterTilesAlreadyExisting(paths: [MKTileOverlayPath]) -> [MKTileOverlayPath] {
    return paths.filter {
      let file = "z\($0.z)x\($0.x)y\($0.y).jpeg"
      let grPath = documentsDirectory.appendingPathComponent(Directory.rando.rawValue).appendingPathComponent(file).path
      let cachePath = documentsDirectory.appendingPathComponent(Directory.cache.rawValue).appendingPathComponent(file).path
      return !FileManager.default.fileExists(atPath: grPath) && !FileManager.default.fileExists(atPath: cachePath)
    }
  }
  
  private func createDirectoriesIfNecessary() {
    let cache = documentsDirectory.appendingPathComponent(Directory.cache.rawValue)
    let rando = documentsDirectory.appendingPathComponent(Directory.rando.rawValue)
    try? FileManager.default.createDirectory(at: cache, withIntermediateDirectories: true, attributes: [:])
    try? FileManager.default.createDirectory(at: rando, withIntermediateDirectories: true, attributes: [:])
    let gpx = documentsDirectory.appendingPathComponent(Directory.trails.rawValue)
    try? FileManager.default.createDirectory(at: gpx, withIntermediateDirectories: true, attributes: [:])
  }
  
}