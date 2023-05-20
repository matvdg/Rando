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
import Combine
import GPXKit

let mockLoc1 = Location(latitude: 42.835191, longitude: 0.872005, altitude: 1944)
let mockLoc2 = Location(latitude: 42.835181, longitude: 0.862005, altitude: 2000)

class TrailManager: ObservableObject {
    
    static let shared = TrailManager()
    
    private var documentsDirectory: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! }
    
    @Published var trails: ObservableArray<Trail> = try! ObservableArray(array: []).observeChildrenChanges(Trail.self)
        
    var currentTrails: [Trail] {
        self.trails.array.filter { $0.isDisplayed }
    }
    
    var departments: [String] {
        var departments = ["all".localized]
        departments.append(contentsOf: trails.array.compactMap { $0.department }.removingDuplicates() )
        return departments
    }
    
    var cancellables = [AnyCancellable]()

    
    init() {
        getTrails()
    }
    
    // MARK: - Public methods
    func createTrail(from url: URL) {
        guard let xml = try? String(contentsOf: url) else { return }
        var locations = [Location]()
        let parser = GPXFileParser(xmlString: xml)
            switch parser.parse() {
            case .success(let track):
                locations.append(contentsOf: track.trackPoints.map { Location(coordinate: $0.coordinate)})
            case .failure(let error):
                print(error)
            }
        guard let loc = locations.last?.clLocation else { return }
        LocationManager.shared.getDepartment(location: loc) { department in
            let trail = Trail(gpx: Gpx(name: url.lastPathComponent.name, locations: locations, department: department))
            self.persist(trail: trail)
            self.trails.array.append(trail)
            self.objectWillChange.send()
        }
    }
    
    
    func doSomethingWith(_ track: GPXTrack) {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.maximumFractionDigits = 1
        let trackGraph = track.graph
        print("Track length: \(formatter.string(from: Measurement<UnitLength>(value: trackGraph.distance, unit: .meters)))")
        print("Track elevation: \(formatter.string(from: Measurement<UnitLength>(value: trackGraph.elevationGain, unit: .meters)))")
        
        for point in track.trackPoints {
            print("Lat: \(point.coordinate.latitude), lon: \(point.coordinate.longitude)")
        }
    }
    
    func save(trail: Trail) {
        let index = trails.array.firstIndex { $0.id == trail.id}
        if let i = index {
            trails.array[i] = trail
            trail.objectWillChange.send()
            self.objectWillChange.send()
        }
        self.persist(trail: trail)
    }
    
    func remove(id: UUID) {
        let file = "trails/\(id).json"
        let filename = documentsDirectory.appendingPathComponent(file)
        do {
            try FileManager.default.removeItem(at: filename)
            trails.array.removeAll { $0.id == id }
            self.objectWillChange.send()
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
        self.trails.array = trails ?? []
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
    
    private func persist(trail: Trail) {
        let file = "trails/\(trail.id).json"
        let filename = documentsDirectory.appendingPathComponent(file)
        do {
            let data = try JSONEncoder().encode(trail.gpx)
            try data.write(to: filename)
        } catch {
            print("❤️ PersistLocallyError = \(error)")
        }
    }
    
}
