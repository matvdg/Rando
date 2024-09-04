//
//  TrailManager.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import Combine
import CoreGPX

let mockLoc1 = Location(latitude: 42.835191, longitude: 0.872005, altitude: 1944)
let mockLoc2 = Location(latitude: 42.835181, longitude: 0.862005, altitude: 2000)

class TrailManager: ObservableObject {
    
    static let shared = TrailManager()
        
    @Published var trails: ObservableArray<Trail> = try! ObservableArray(array: []).observeChildrenChanges(Trail.self)
    
    var currentTrails: [Trail] {
        self.trails.array.filter { $0.isDisplayed }
    }
    
    var departments: [String] {
        var departments = ["all"]
        departments.append(contentsOf: trails.array.compactMap { $0.department }.removingDuplicates() )
        return departments
    }
    
    private var cancellables = [AnyCancellable]()
    
    private var metadataQuery: NSMetadataQuery?
    
    private var notificationsLocked: Bool = false
    
    init() {
        getTrails()
    }
    
    // MARK: - Public methods
    @objc private func queryDidUpdate(_ notification: Notification) {
        DispatchQueue.main.async {
            guard !self.notificationsLocked else { return }
            self.notificationsLocked = true
            Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
                self.notificationsLocked = false
                self.getTrails()
                print("􂆍 iCloud update for trails")
            }
        }
    }
    
    func watchiCloud() {
        DispatchQueue.main.async {
            self.metadataQuery = NSMetadataQuery()
            self.metadataQuery?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
            self.metadataQuery?.predicate = NSPredicate(format: "%K == %@", NSMetadataItemFSNameKey, "trails")
            NotificationCenter.default.addObserver(self, selector: #selector(self.queryDidUpdate(_:)), name: .NSMetadataQueryDidUpdate, object: self.metadataQuery)
            self.metadataQuery?.start()
        }
    }
    
    func unwatchiCloud() {
        NotificationCenter.default.removeObserver(self)
        metadataQuery?.stop()
    }
    
    func loadTrails(from urls: [URL]) -> [Trail] {
        return urls.compactMap { url -> Trail? in
            let gpx = GPXParser(withURL: url)?.parsedData()
            let points = gpx?.tracks.first?.segments.first?.points
            guard let points else { return nil }
            let locations = points.compactMap { point -> Location? in
                if let lat = point.latitude, let lng = point.longitude {
                    return Location(latitude: lat, longitude: lng, altitude: point.elevation ?? 0)
                } else {
                    return nil
                }
            }
            let name = (gpx?.metadata?.name ?? gpx?.tracks.first?.name ?? url.lastPathComponent.name).cleanHtmlString
            let description = (gpx?.metadata?.desc ?? gpx?.tracks.first?.desc ?? "").cleanHtmlString
            return Trail(gpx: Gpx(name: name, description: description, locations: locations))
        }
    }
    
    func exportToGpxFile(trail: Trail) -> URL {
        let root = GPXRoot(creator: "Rando Pyrénées")
        let trackpoints = trail.locations.map {
            let tp = GPXTrackPoint(latitude: $0.latitude, longitude: $0.longitude)
            tp.elevation = $0.altitude
            return tp
        }
        let track = GPXTrack()
        let tracksegment = GPXTrackSegment()
        tracksegment.add(trackpoints: trackpoints)
        track.add(trackSegment: tracksegment)
        root.add(track: track)
        let meta = GPXMetadata()
        meta.name = trail.name
        meta.desc = trail.description
        root.metadata = meta
        let gpx = root.gpx()
        // Save file
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(trail.name).gpx")
        print("Saving file at path: \(fileURL)")
        // write gpx to file
        var writeError: Error?
        let saved: Bool
        do {
            try gpx.write(toFile: fileURL.path, atomically: true, encoding: String.Encoding.utf8)
            saved = true
        } catch let error {
            writeError = error
            saved = false
        }
        if !saved {
            if let error = writeError {
                print("[ERROR] GPXFileManager:save: \(error.localizedDescription)")
            }
        }
        return fileURL
    }
        
    func save(trails: [Trail]) {
        trails.forEach { save(trail: $0) }
    }
    
    func save(trail: Trail) {
        let index = trails.array.firstIndex { $0.id == trail.id}
        if let i = index {
            trails.array[i] = trail
            trail.objectWillChange.send()
            self.objectWillChange.send()
        } else {
            trails.array.append(trail)
            self.objectWillChange.send()
        }
        self.persist(gpx: trail.gpx)
    }
    
    func remove(id: UUID) {
        let file = "trails/\(id).json"
        let filename = FileManager.documentsDirectory.appendingPathComponent(file)
        do {
            try FileManager.default.removeItem(at: filename)
            trails.array.removeAll { $0.id == id }
            self.objectWillChange.send()
        } catch {
            print("􀈾 RemoveItemError = \(error)")
        }
    }
    
    func getTrails() {
        loadDemoTrails()
        let urls = try? FileManager.default.contentsOfDirectory(at: FileManager.documentsDirectory.appendingPathComponent("trails"), includingPropertiesForKeys: nil).filter { $0.pathExtension == "json" }
        let trails = urls?.compactMap { url -> Trail? in
            do {
                let data = try Data(contentsOf: url)
                let gpx = try JSONDecoder().decode(Gpx.self, from: data)
                return Trail(gpx: gpx)
            } catch {
                switch error {
                case DecodingError.keyNotFound(let key, let context): print("􀈾 Trail decoding error = \(error.localizedDescription), key not found = \(key), context = \(context)")
                default: print("􀈾 Trail decoding error = \(error.localizedDescription)")
                }
                return nil
            }
        }
        self.trails.array = trails ?? []
        self.objectWillChange.send()
    }
    
    func addMissingDepartment(trail: Trail) {
        Task(priority: .background) {
            guard trail.department == nil, let loc = trail.locations.last?.clLocation else { return }
            LocationManager.shared.getDepartment(location: loc) { department in
                trail.department = department
                self.save(trail: trail)
            }
        }
    }
    
    func restoreDemoTrails() {
        UserDefaults.hasBeenLaunched = false
        self.getTrails()
    }
    
    func removeAllTrailsVisibleOnTheMap() {
        trails.array.forEach { $0.isDisplayed = false }
        save(trails: trails.array)
    }
    
    func showGR10andHRPOnTheMap() {
        trails.array.forEach {
            if $0.name.contains("HRP") {
                $0.isDisplayed = true
                $0.color = UIColor.blue.cgColor
                $0.lineWidth = defaultLineWidth
            }
            if $0.name.contains("GR10") {
                $0.isDisplayed = true
                $0.color = UIColor.red.cgColor
                $0.lineWidth = defaultLineWidth
            }
            if $0.name.contains("Variante GR10") {
                $0.isDisplayed = true
                $0.color = UIColor.orange.cgColor
                $0.lineWidth = defaultLineWidth
            }
        }
        save(trails: trails.array)
    }
    
    // MARK: - Private methods
    private func loadDemoTrails() {
        guard !UserDefaults.hasBeenLaunched else { return }
        try? FileManager.default.createDirectory(at: FileManager.documentsDirectory.appendingPathComponent("trails"), withIntermediateDirectories: true, attributes: [:])
        Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil)?.forEach { url in
            guard url.lastPathComponent != "pois.json" else { return }
            do {
                try FileManager.default.copyItem(at: url, to: FileManager.documentsDirectory.appendingPathComponent("trails/\(url.lastPathComponent)"))
            } catch {
                print(error)
            }
        }
    }
    
    private func persist(gpx: Gpx) {
        let file = "trails/\(gpx.id).json"
        let filename = FileManager.documentsDirectory.appendingPathComponent(file)
        do {
            let data = try JSONEncoder().encode(gpx)
            try data.write(to: filename)
        } catch {
            print("􀌓 Trail persistLocallyError = \(error)")
        }
    }
    
}
