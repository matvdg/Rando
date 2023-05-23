import Foundation
import MapKit

typealias TileCoordinates = (x: Int, y: Int, z: Int)

class IGNV2Overlay: MKTileOverlay {
    override func url(forTilePath path: MKTileOverlayPath) -> URL { TileManager.shared.getTileOverlay(for: path) }
}

class IGN25Overlay: MKTileOverlay {
    override func url(forTilePath path: MKTileOverlayPath) -> URL { TileManager.shared.getTileOverlay(for: path) }
}

class OpenTopoMapOverlay: MKTileOverlay {
    override func url(forTilePath path: MKTileOverlayPath) -> URL { TileManager.shared.getTileOverlay(for: path) }
}

class OpenStreetMapOverlay: MKTileOverlay {
    override func url(forTilePath path: MKTileOverlayPath) -> URL { TileManager.shared.getTileOverlay(for: path) }
}

class TileManager: ObservableObject {
    
    enum DownloadStatus: Equatable {
        case idle, downloading(id: UUID)
    }
    
    static let shared = TileManager()
    
    init() {
        print("❤️ DocumentsDirectory = \(documentsDirectory)")
        createDirectoriesIfNecessary()
    }
    
    // MARK: -  Private properties
    
    private var documentsDirectory: URL { fileManager.urls(for: .documentDirectory, in: .userDomainMask).first! }
    
    private let fileManager = FileManager.default
    
    // MARK: -  Public property
    @Published var progress: Float = 0
    @Published var status: DownloadStatus = .idle
    
    // MARK: -  Public methods
    func hasBeenDownloaded(for boundingBox: MKMapRect) -> Bool {
        getEstimatedDownloadSize(for: boundingBox) == 0
    }
    
    func getEstimatedDownloadSize(for boundingBox: MKMapRect) -> Double {
        let paths = self.computeTileOverlayPaths(boundingBox: boundingBox)
        let count = self.filterTilesAlreadyExisting(paths: paths).count
        let size: Double = 30000 // Bytes (average size)
        return Double(count) * size
    }
    
    func getDownloadedSize(for boundingBox: MKMapRect) -> Double {
        let layer = UserDefaults.currentLayer.fallbackLayer.rawValue
        let paths = self.computeTileOverlayPaths(boundingBox: boundingBox)
        var accumulatedSize: UInt64 = 0
        for path in paths {
            let file = "\(layer)/z\(path.z)x\(path.x)y\(path.y).png"
            let url = documentsDirectory.appendingPathComponent(file)
            accumulatedSize += (try? url.regularFileAllocatedSize()) ?? 0
        }
        return Double(accumulatedSize)
    }
    
    /// Download and persist all tiles within the boundingBox
    func download(trail: Trail) async {
        guard status == .idle else { return }
        await NetworkManager.shared.runIfNetwork()
        self.status = .downloading(id: trail.id)
        self.progress = 0.01
        let paths = self.computeTileOverlayPaths(boundingBox: trail.boundingBox)
        let filteredPaths = self.filterTilesAlreadyExisting(paths: paths)
        for i in 0..<filteredPaths.count {
            await self.persistLocally(path: filteredPaths[i])
            self.progress = Float(i) / Float(filteredPaths.count)
        }
        DispatchQueue.main.async {
            NotificationManager.shared.sendNotification(title: "\("Downloaded".localized) (\((self.getDownloadedSize(for: trail.boundingBox)).toBytes))", message: "\(trail.name) \("DownloadedMessage".localized)")
            self.progress = 0
            self.status = .idle
        }
    }
    
    func getTileOverlay(for path: MKTileOverlayPath) -> URL {
        let layer = UserDefaults.currentLayer.fallbackLayer.rawValue
        let file = "z\(path.z)x\(path.x)y\(path.y).png"
        // Check is tile is already available
        let tilesUrl = documentsDirectory.appendingPathComponent("\(layer)").appendingPathComponent(file)
        if fileManager.fileExists(atPath: tilesUrl.path) {
            return tilesUrl
        } else {
            return persistLocally(path: path)
        }
    }
    
    // MARK: -  Private methods
    private func computeTileOverlayPaths(boundingBox box: MKMapRect, maxZ: Int = 17) -> [MKTileOverlayPath] {
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
    
    @discardableResult private func persistLocally(path: MKTileOverlayPath) -> URL {
        let overlay: MKTileOverlay
        let layer = UserDefaults.currentLayer.fallbackLayer
        switch layer {
        case .ign:
            overlay = MKTileOverlay(urlTemplate: "https://wxs.ign.fr/pratique/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.PLANIGNV2&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fpng&TileMatrix={z}&TileCol={x}&TileRow={y}")
        case .openStreetMap:
            overlay = MKTileOverlay(urlTemplate: "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png")
        case .openTopoMap:
            overlay = MKTileOverlay(urlTemplate: "https://b.tile.opentopomap.org/{z}/{x}/{y}.png")
        default: //IGN25:
            overlay = MKTileOverlay(urlTemplate: "https://wxs.ign.fr/an7nvfzojv5wa96dsga5nk8w/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.MAPS&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fjpeg&TileMatrix={z}&TileCol={x}&TileRow={y}")
        }
        let url = overlay.url(forTilePath: path)
        let file = "\(layer.rawValue)/z\(path.z)x\(path.x)y\(path.y).png"
        let filename = documentsDirectory.appendingPathComponent(file)
        do {
            let data = try Data(contentsOf: url)
            try data.write(to: filename)
        } catch {
            print("❤️ PersistLocallyError = \(error)")
        }
        return url
    }
    
    @discardableResult private func persistLocally(path: MKTileOverlayPath) async -> URL {
        let layer = UserDefaults.currentLayer.fallbackLayer
        let overlay: MKTileOverlay
        switch layer {
        case .ign:
            overlay = MKTileOverlay(urlTemplate: "https://wxs.ign.fr/pratique/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.PLANIGNV2&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fpng&TileMatrix={z}&TileCol={x}&TileRow={y}")
        case .openStreetMap:
            overlay = MKTileOverlay(urlTemplate: "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png")
        case .openTopoMap:
            overlay = MKTileOverlay(urlTemplate: "https://b.tile.opentopomap.org/{z}/{x}/{y}.png")
        default: // IGN25
            overlay = MKTileOverlay(urlTemplate: "https://wxs.ign.fr/an7nvfzojv5wa96dsga5nk8w/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.MAPS&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fjpeg&TileMatrix={z}&TileCol={x}&TileRow={y}")
        }
                                        
        // SwissTopo (removed because Rando "Pyrénées", but in case we go someday in Switzerland, I keep this link safe..."https://wmts.geo.admin.ch/1.0.0/ch.swisstopo.pixelkarte-farbe/default/current/3857/{z}/{x}/{y}.jpeg")
        let url1 = overlay.url(forTilePath: path)
        let file = "\(layer.rawValue)/z\(path.z)x\(path.x)y\(path.y).png"
        let filename = documentsDirectory.appendingPathComponent(file)
        do {
            let data = try Data(contentsOf: url1)
            try data.write(to: filename)
        } catch {
            print("❤️ PersistLocallyError = \(error)")
        }
        return url1
    }
    
    private func filterTilesAlreadyExisting(paths: [MKTileOverlayPath]) -> [MKTileOverlayPath] {
        let layer = UserDefaults.currentLayer.fallbackLayer.rawValue
        return paths.filter {
            let file = "z\($0.z)x\($0.x)y\($0.y).png"
            let tilesPath = documentsDirectory.appendingPathComponent("\(layer)").appendingPathComponent(file).path
            return !fileManager.fileExists(atPath: tilesPath)
        }
    }
    
    private func createDirectoriesIfNecessary() {
        Layer.allCases.forEach { layer in
            let tiles = documentsDirectory.appendingPathComponent(layer.fallbackLayer.rawValue)
            try? fileManager.createDirectory(at: tiles, withIntermediateDirectories: true, attributes: [:])
        }
    }
    
}
