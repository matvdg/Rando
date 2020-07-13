//
//  TrailManager.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

let araing = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 42.835191, longitude: 0.872005), altitude: 1944, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: Date()) // Etang d'Araing
let mockLoc1 = Location(latitude: 42.835191, longitude: 0.872005, altitude: 1944)
let mockLoc2 = Location(latitude: 42.835181, longitude: 0.862005, altitude: 2000)

typealias Estimations = (distance: String, positiveElevation: String, negativeElevation: String, duration: String)


class TrailManager: ObservableObject {
    
    static let shared = TrailManager()
    
    private var documentsDirectory: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! }
    
    @Published var trails = [Trail]()
    var currentLocations = [CLLocation]()
    var currentLocationsCoordinate: [CLLocationCoordinate2D] { currentLocations.map { $0.coordinate } }
    
    lazy var polyline = MKPolyline(coordinates: currentLocationsCoordinate, count: currentLocations.count)
    lazy var boundingBox = polyline.boundingMapRect
    
    init() {
        currentLocations = [araing]
        getTrails()
    }
    
    // MARK: - Public method
    func createTrail(from url: URL) {
        guard let contents = try? String(contentsOf: url) else { return }
        let lines = contents.components(separatedBy: "\n")
        var locations = [Location]()
        for (i, line) in lines.enumerated() {
            guard let lat = line.latitude, let lng = line.longitude else { continue }
            locations.append(Location(latitude: lat, longitude: lng, altitude: i + 1 < lines.count ? lines[i + 1].altitude ?? 0 : 0))
        }
        let trail = Trail(gpx: Gpx(name: url.lastPathComponent.name, locations: locations))
        save(trail: trail)
    }
    
    func closestAltitude(from coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        currentLocations[minimumDistanceToPolyline(from: coordinate).index].altitude
    }
    
    func estimations(for poi: Poi) -> Estimations {
        
        let date = Date()
        
        let minDistanceToUser = minimumDistanceToPolyline(from: LocationManager.shared.currentPosition.coordinate)
        let minDistanceToPoi = minimumDistanceToPolyline(from: poi.coordinate)
        
        var distance: CLLocationDistance = minDistanceToUser.distance + minDistanceToPoi.distance
        var positiveElevation: CLLocationDistance = 0
        var negativeElevation: CLLocationDistance = 0
        
        let indexes = [minDistanceToUser.index, minDistanceToPoi.index].sorted { $0 < $1 }
        
        for i in indexes[0]..<indexes[1] {
            distance += currentLocations[i].distance(from: currentLocations[i+1])
            let elevation = currentLocations[i+1].altitude - currentLocations[i].altitude
            if elevation > 0 {
                positiveElevation += elevation
            } else {
                negativeElevation += elevation
            }
        }
        
        // Add elevation to POI (usefull if the POI is outside the Rando polyline like a summit)
        let elevation = poi.alt - currentLocations[minDistanceToPoi.index].altitude
        if elevation > 0 {
            positiveElevation += elevation
        } else {
            negativeElevation += elevation
        }
        // At the contrary we don't add elevation from the user if he is outside the Rando polyline as the elevation from the GPS is not accurate, particularly in mountains and if the user is far away from the Rando (at home, looking at the app for example from Toulouse, so the elevation added would have been irrelevant)
        
        print("❤️ Elapsed time to compute polyline distance & elevation = \(Date().timeIntervalSince(date))s")
        let duration = getDurationEstimation(distance: distance, positiveElevation: positiveElevation)
        return (distance.toString, positiveElevation.toString, abs(negativeElevation).toString, duration)
    }
    
    func save(trail: Trail) {
        let file = "\(Directory.trails.rawValue)/\(trail.id).json"
        let filename = documentsDirectory.appendingPathComponent(file)
        do {
            let data = try JSONEncoder().encode(trail.gpx)
            try data.write(to: filename)
            self.getTrails()
        } catch {
            print("❤️ PersistLocallyError = \(error)")
        }
    }
    
    func remove(id: UUID) {
        let file = "\(Directory.trails.rawValue)/\(id).json"
        let filename = documentsDirectory.appendingPathComponent(file)
        do {
            try FileManager.default.removeItem(at: filename)
        } catch {
            print("❤️ RemoveItemError = \(error)")
        }
    }
    
    // MARK: - Private methods
    private func getTrails() {
        let urls = try? FileManager.default.contentsOfDirectory(at: documentsDirectory.appendingPathComponent(Directory.trails.rawValue), includingPropertiesForKeys: nil).filter { $0.pathExtension == "json" }
        let trails = urls?.compactMap { url -> Trail? in
            do {
                let data = try Data(contentsOf: url)
                let gpx = try JSONDecoder().decode(Gpx.self, from: data)
                return Trail(gpx: gpx)
            } catch {
                switch error {
                case DecodingError.keyNotFound(let key, let context): print("❤️ Error = \(error.localizedDescription), key not found = \(key), context = \(context)")
                default: print("❤️ Error = \(error.localizedDescription)")
                }
                return nil
            }
        }
        self.trails = trails ?? []
    }
    
    private func minimumDistanceToPolyline(from coordinate: CLLocationCoordinate2D) -> (distance: CLLocationDistance, index: Int) {
        var index = 0
        var minDistance: CLLocationDistance = .infinity
        
        for (i, loc) in currentLocationsCoordinate.enumerated() {
            let distance = loc.distance(from: coordinate)
            guard distance < minDistance else { continue }
            minDistance = distance
            index = i
        }
        
        return (minDistance, index)
    }
    
    private func getDurationEstimation(distance: CLLocationDistance, positiveElevation: CLLocationDistance) -> String {
        let speed: CLLocationSpeed = 1.111 // 4Km.h-1
        let totalDistance = distance + 10 * positiveElevation
        let duration = totalDistance/speed
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
    
    
    
}

extension String {
    
    var altitude: Double? {
        guard let rangeFrom = range(of: "<ele>")?.upperBound, let rangeTo = self[rangeFrom...].range(of: "</ele>")?.lowerBound else { return nil }
        return Double(String(self[rangeFrom..<rangeTo]))
    }
    
    var latitude: Double? {
        guard let rangeFrom = range(of: "<trkpt lat=\"")?.upperBound, let rangeTo = self[rangeFrom...].range(of: "\"")?.lowerBound else { return nil }
        return Double(String(self[rangeFrom..<rangeTo]))
    }
    
    var longitude: Double? {
        guard let rangeFrom = range(of: "lon=\"")?.upperBound, let rangeTo = self[rangeFrom...].range(of: "\"")?.lowerBound else { return nil }
        return Double(String(self[rangeFrom..<rangeTo]))
    }
    
    var name: String {
        var clean = self
        clean = clean.replacingOccurrences(of: ".gpx", with: "")
        clean = clean.replacingOccurrences(of: "-", with: " ")
        clean = clean.replacingOccurrences(of: "_", with: " ")
        return clean.capitalized
    }
    
}
