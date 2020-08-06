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

let mockLoc1 = Location(latitude: 42.835191, longitude: 0.872005, altitude: 1944)
let mockLoc2 = Location(latitude: 42.835181, longitude: 0.862005, altitude: 2000)

class TrailManager: ObservableObject {
    
    static let shared = TrailManager()
    
    private var documentsDirectory: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! }
    
    @Published var trails = [Trail]()
    
    var currentTrails: [Trail] {
        self.trails.filter { $0.isDisplayed }
    }
    
    var departments: [String] {
        var departments = ["all".localized]
        departments.append(contentsOf: trails.compactMap { $0.department }.removingDuplicates() )
        return departments
    }
    
    
    init() {
        getTrails()
    }
    
    // MARK: - Public methods
    func createTrail(from url: URL) {
        guard let contents = try? String(contentsOf: url) else { return }
        let lines = contents.components(separatedBy: "\n")
        var locations = [Location]()
        for (i, line) in lines.enumerated() {
            guard let lat = line.latitude, let lng = line.longitude else { continue }
            locations.append(Location(latitude: lat, longitude: lng, altitude: i + 1 < lines.count ? lines[i + 1].altitude ?? 0 : 0))
        }
        
        guard let loc = locations.last?.clLocation else { return }
        LocationManager.shared.getDepartment(location: loc) { department in
            let trail = Trail(gpx: Gpx(name: url.lastPathComponent.name, locations: locations, department: department))
            self.save(trail: trail)
        }
        
    }
    
    func save(trail: Trail) {
        let file = "trails/\(trail.id).json"
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
        let file = "trails/\(id).json"
        let filename = documentsDirectory.appendingPathComponent(file)
        do {
            try FileManager.default.removeItem(at: filename)
        } catch {
            print("❤️ RemoveItemError = \(error)")
        }
    }
    
    func getTrails() {
        loadDemoTrails()
        let urls = try? FileManager.default.contentsOfDirectory(at: documentsDirectory.appendingPathComponent("trails"), includingPropertiesForKeys: nil).filter { $0.pathExtension == "json" }
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
        
    func addMissingDepartment(trail: Trail) {
        guard trail.department == nil, let loc = trail.locations.last?.clLocation else { return }
        LocationManager.shared.getDepartment(location: loc) { department in
            trail.department = department
            TrailManager.shared.save(trail: trail)
        }
    }
    
    // MARK: - Private methods
    private func loadDemoTrails() {
        guard !UserDefaults.hasBeenLaunched else { return }
        try? FileManager.default.createDirectory(at: documentsDirectory.appendingPathComponent("trails"), withIntermediateDirectories: true, attributes: [:])
        Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil)?.forEach { url in
            guard url.lastPathComponent != "pois.json" else { return }
            do {
                try FileManager.default.copyItem(at: url, to: documentsDirectory.appendingPathComponent("trails/\(url.lastPathComponent)"))
            } catch {
                print(error)
            }
        }
    }
    
}
