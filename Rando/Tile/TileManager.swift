import Foundation
import MapKit
import Semaphore

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

class SwissTopoMapOverlay: MKTileOverlay {
    override func url(forTilePath path: MKTileOverlayPath) -> URL { TileManager.shared.getTileOverlay(for: path, layer: .swissTopo) }
}


class TileManager: ObservableObject {
    
    enum DownloadState: Equatable {
        case idle, downloading(id: UUID)
        func isDownloading() -> Bool {
            guard case .downloading = self else { return false }
            return true
        }
        func isIdle() -> Bool {
            guard case .idle = self else { return false }
            return true
        }
        func isDownloadingAnotherTrail(id: UUID) -> Bool {
            switch self {
            case .idle:
                return false
            case .downloading(id: let id2):
                if id == id2 {
                    return false
                } else {
                    return true
                }
            }
        }
        func isDownloadingTrail(id: UUID) -> Bool {
            switch self {
            case .idle:
                return false
            case .downloading(id: let id2):
                if id == id2 {
                    return true
                } else {
                    return false
                }
            }
        }
    }
    
    static let shared = TileManager()
    
    init() {
        semaphore = AsyncSemaphore(value: 5)
        // Useless when iCloud print("􀈝 DocumentsDirectory = \(FileManager.documentsDirectory.relativeString.replacingOccurrences(of: "file://", with: ""))")
        createDirectoriesIfNecessary()
    }
    
    // MARK: -  Private properties
    private let tileSize: Double = 30000 // Bytes (average size of a tile)
    private var sizeLeftInBytes: Double = 0
    private let fileManager = FileManager.default
    private var currentFilteredPaths = [MKTileOverlayPath]() // Without those already persisted
    private var downloadTilesTask: Task<(), Never>?
    private let semaphore: AsyncSemaphore
    
    // MARK: -  Public property
    @Published var progress: Float = 0
    var sizeLeft: String { sizeLeftInBytes.toBytesString }
    var hasBeenDownloaded: Bool = false
    var state: DownloadState = .idle
    
    // MARK: -  Public methods
    
    /// Load TrailManager computations for TrailDetailView if TileManager available
    /// - Parameters:
    ///   - trail: the concerned Trail
    func load(for trail: Trail, selectedLayer: Layer) {
        guard state.isIdle() else { return } // No override if currently downloading for another trail for another TrailDetailView
        self.downloadTilesTask?.cancel() // Just in case
        Task(priority: .userInitiated) {
            let paths = computeAndFilterTileOverlayPaths(for: trail.boundingBox, layer: selectedLayer)
            sizeLeftInBytes = Double(paths.count) * tileSize // Update estimation
            DispatchQueue.main.async { [weak self] in
                // Update trail state from .unknown to...
                if let isDownloading = self?.state.isDownloadingTrail(id: trail.id), isDownloading {
                    trail.downloadState = .downloading
                } else {
                    trail.downloadState = paths.isEmpty ? .downloaded : .notDownloaded
                }
            }
        }
        
    }
    
    /// Download and persist all tiles within the boundingBox (sync main thread UI public method)
    /// - Parameters:
    ///   - trail: the concerned Trail
    ///   - layer: selectedLayer we want to download
    func download(trail: Trail, layer: Layer) {
        Feedback.selected() // Give user feedback
        trail.downloadState = .downloading // Sync. Immediate UI update before we go async
        self.downloadTilesTask = Task(priority: .background) { // Async
            do {
                try await download(trail: trail, layer: layer)
                DispatchQueue.main.async { [weak self] in
                    NotificationManager.shared.sendNotification(title: "\("downloaded".localized) (\(((self?.getDownloadedSize(for: trail.boundingBox, layer: layer)) ?? 0).toBytesString))", message: "\(trail.name) \("downloadedMessage".localized)")
                    self?.progress = 1
                    self?.state = .idle
                    trail.downloadState = .downloaded
                    print("􀢓 Downloaded \(trail.name) maps, for \(layer) layer")
                    Feedback.success()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    if let errorDomain = error as? URLError, errorDomain.code != .cancelled {
                        NotificationManager.shared.sendNotification(title: "error", message: "network")
                    }
                    self?.state = .idle
                    trail.downloadState = .notDownloaded
                    print("􀌓 Download cancelled: \(error)")
                    self?.downloadTilesTask?.cancel()
                    Feedback.failed()
                }
            }
        }
    }
    
    /// Cancel download
    /// - Parameters:
    ///   - trail: the concerned Trail
    func cancelDownload(trail: Trail) {
        Feedback.selected() // Give user feedback
        print("􀌓 User cancelled download")
        self.downloadTilesTask?.cancel()
        self.state = .idle
        trail.downloadState = .notDownloaded
    }
    
    /// Remove all tiles of the specified layer
    /// - Parameters:
    ///   - layer: selectedLayer we want to remove
    func remove(layer: Layer) {
        try? FileManager.default.removeItem(at: FileManager.documentsDirectory.appendingPathComponent(layer.rawValue))
        createDirectoriesIfNecessary()
    }
    
    /// Get downloaded size for all tiles of the specified layer
    /// - Parameters:
    ///   - layer: selectedLayer
    func getDownloadedSize(layer: Layer) -> Double { FileManager.documentsDirectory.appendingPathComponent(layer.rawValue).allocatedSizeOfDirectory }
    
    /// Get the tile URL for the specified layer and path (streaming tile in live, persist it if necessary)
    /// - Parameters:
    ///   - path: MKTileOverlayPath
    ///   - layer: selectedLayer for which we want tile URL
    /// - Returns: URL from local cache OR download and persist tile and give the URL
    func getTileOverlay(for path: MKTileOverlayPath, layer: Layer) -> URL {
        let file = "z\(path.z)x\(path.x)y\(path.y).png"
        // Check is tile is already available
        let tilesUrl = FileManager.documentsDirectory.appendingPathComponent("\(layer.rawValue)").appendingPathComponent(file)
        if fileManager.fileExists(atPath: tilesUrl.path) {
            return tilesUrl
        } else {
            return persistLocally(path: path, layer: layer)
        }
    }
    
    // MARK: -  Sync private methods
    private func persistLocally(path: MKTileOverlayPath, layer: Layer) -> URL {
        let overlay: MKTileOverlay
        switch layer {
        case .ign:
            overlay = MKTileOverlay(urlTemplate: "https://wxs.ign.fr/pratique/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.PLANIGNV2&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fpng&TileMatrix={z}&TileCol={x}&TileRow={y}")
        case .openStreetMap:
            overlay = MKTileOverlay(urlTemplate: "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png")
        case .openTopoMap:
            overlay = MKTileOverlay(urlTemplate: "https://b.tile.opentopomap.org/{z}/{x}/{y}.png")
        case .swissTopo:
            overlay = MKTileOverlay(urlTemplate: "https://wmts.geo.admin.ch/1.0.0/ch.swisstopo.pixelkarte-farbe/default/current/3857/{z}/{x}/{y}.jpeg")
        default: //IGN25:
            overlay = MKTileOverlay(urlTemplate: "https://wxs.ign.fr/an7nvfzojv5wa96dsga5nk8w/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.MAPS&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fjpeg&TileMatrix={z}&TileCol={x}&TileRow={y}")
        }
        let url = overlay.url(forTilePath: path)
        Task(priority: .background) { // Persist layer (async)...
            let file = "\(layer.rawValue)/z\(path.z)x\(path.x)y\(path.y).png"
            let filename = FileManager.documentsDirectory.appendingPathComponent(file)
            if !fileManager.fileExists(atPath:  filename.path)  { // Recheck if file is absent to avoid conflict with the async persistLocally method in case of parallel download of the maps while the map tiles are still streaming (e.g. user loads a TrailDetailView, but immediately clicks on download while the tilesl of the preview map are still loading
                do {
                    let response = try await URLSession.shared.data(from: url)
                    try response.0.write(to: filename)
                }
                catch {
                    print("􀌓 TileManager persistLocallyError = \(error)")
                }
            } else {
                print("􀌓 TileManager persistLocallyError already downloaded by other async process ")
            }
        }
        return url // ...but stream now (sync)
    }
    
    private func createDirectoriesIfNecessary() {
        Layer.onlyOverlaysLayers.forEach { layer in
            let tiles = FileManager.documentsDirectory.appendingPathComponent(layer.rawValue)
            try? fileManager.createDirectory(at: tiles, withIntermediateDirectories: true, attributes: [:])
        }
    }
    
    private func tranformCoordinate(coordinates: CLLocationCoordinate2D , zoom: Int) -> TileCoordinates {
        let lng = coordinates.longitude
        let lat = coordinates.latitude
        let tileX = Int(floor((lng + 180) / 360.0 * pow(2.0, Double(zoom))))
        let tileY = Int(floor((1 - log( tan( lat * Double.pi / 180.0 ) + 1 / cos( lat * Double.pi / 180.0 )) / Double.pi ) / 2 * pow(2.0, Double(zoom))))
        return (tileX, tileY, zoom)
    }
    
    private func computeAndFilterTileOverlayPaths(for boundingBox: MKMapRect, layer: Layer, filtered: Bool = true) -> [MKTileOverlayPath] {
        guard state == .idle else { return currentFilteredPaths }
        var paths = [MKTileOverlayPath]()
        for z in 1...17 {
            let topLeft = tranformCoordinate(coordinates: MKMapPoint(x: boundingBox.minX, y: boundingBox.minY).coordinate, zoom: z)
            let topRight = tranformCoordinate(coordinates: MKMapPoint(x: boundingBox.maxX, y: boundingBox.minY).coordinate, zoom: z)
            let bottomLeft = tranformCoordinate(coordinates: MKMapPoint(x: boundingBox.minX, y: boundingBox.maxY).coordinate, zoom: z)
            for x in topLeft.x...topRight.x {
                for y in topLeft.y...bottomLeft.y {
                    paths.append(MKTileOverlayPath(x: x, y: y, z: z, contentScaleFactor: 2))
                }
            }
        }
        if !filtered { return paths}
        currentFilteredPaths = paths.filter {
            let file = "z\($0.z)x\($0.x)y\($0.y).png"
            let tilesPath = FileManager.documentsDirectory.appendingPathComponent("\(layer.rawValue)").appendingPathComponent(file).path
            return !fileManager.fileExists(atPath: tilesPath)
        }
        return currentFilteredPaths
    }
    
    /// Called when download ends
    private func getDownloadedSize(for boundingBox: MKMapRect, layer: Layer) -> Double {
        var accumulatedSize: UInt64 = 0
        for path in computeAndFilterTileOverlayPaths(for: boundingBox, layer: layer, filtered: false) {
            let file = "\(layer.rawValue)/z\(path.z)x\(path.x)y\(path.y).png"
            let url = FileManager.documentsDirectory.appendingPathComponent(file)
            accumulatedSize += (try? url.regularFileAllocatedSize()) ?? 0
        }
        return Double(accumulatedSize)
    }
    
    // MARK: -  Async private method only in downloading state
    private func download(trail: Trail, layer: Layer) async throws {
        guard state == .idle else { return print("􀌓 Another download is in progress") }
        await NetworkManager.shared.runIfNetwork()
        DispatchQueue.main.async { [weak self] in
            self?.progress = 0
            print("􀌕 Downloading \(trail.name) maps, for \(layer) layer")
            self?.state = .downloading(id: trail.id)
            trail.downloadState = .downloading
        }
        let filteredPaths = computeAndFilterTileOverlayPaths(for: trail.boundingBox, layer: layer)
        try Task.checkCancellation()
        let total = filteredPaths.count
        for i in 0..<total {
            try await self.persistLocally(path: filteredPaths[i], layer: layer)
            DispatchQueue.main.async { [weak self] in
                self?.sizeLeftInBytes = Double(total - i) * (self?.tileSize ?? 30000) // Update estimation
                self?.progress = Float(i) / Float(total)
                print( "􀌕 Downloading \(i)/\(total) tiles, \(Int((self?.progress ?? 0) * 100))%")
            }
        }
    }
    
    private func persistLocally(path: MKTileOverlayPath, layer: Layer) async throws {
        try await semaphore.waitUnlessCancelled()
        defer { semaphore.signal() }
        let overlay: MKTileOverlay
        switch layer {
        case .ign:
            overlay = MKTileOverlay(urlTemplate: "https://wxs.ign.fr/pratique/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.PLANIGNV2&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fpng&TileMatrix={z}&TileCol={x}&TileRow={y}")
        case .openStreetMap:
            overlay = MKTileOverlay(urlTemplate: "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png")
        case .openTopoMap:
            overlay = MKTileOverlay(urlTemplate: "https://b.tile.opentopomap.org/{z}/{x}/{y}.png")
        case .swissTopo:
            overlay = MKTileOverlay(urlTemplate: "https://wmts.geo.admin.ch/1.0.0/ch.swisstopo.pixelkarte-farbe/default/current/3857/{z}/{x}/{y}.jpeg")
        default: //IGN25:
            overlay = MKTileOverlay(urlTemplate: "https://wxs.ign.fr/an7nvfzojv5wa96dsga5nk8w/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.MAPS&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fjpeg&TileMatrix={z}&TileCol={x}&TileRow={y}")
        }
        let url = overlay.url(forTilePath: path)
        let file = "\(layer.rawValue)/z\(path.z)x\(path.x)y\(path.y).png"
        let filename = FileManager.documentsDirectory.appendingPathComponent(file)
        let response = try await URLSession.shared.data(from: url)
        try response.0.write(to: filename)
    }
    
}
