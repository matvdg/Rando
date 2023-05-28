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
        var distance: CLLocationDistance?
        var elevationGain: CLLocationDistance?
        var name = ""
        let parser = GPXFileParser(xmlString: xml)
            switch parser.parse() {
            case .success(let track):
                locations.append(contentsOf: track.trackPoints.map { Location(coordinate: $0.coordinate)})
                distance = track.graph.distance
                elevationGain = track.graph.elevationGain
                name = track.title
            case .failure(let error):
                print(error)
            }
        guard let loc = locations.last?.clLocation else { return }
        LocationManager.shared.getDepartment(location: loc) { department in
            let gpx = Gpx(name: name, locations: locations, department: department, distance: distance, elevationGain: elevationGain)
            let trail = Trail(gpx: gpx)
            self.persist(gpx: gpx)
            self.trails.array.append(trail)
            self.objectWillChange.send()
        }
    }
    
    func save(trail: Trail) {
        let index = trails.array.firstIndex { $0.id == trail.id}
        if let i = index {
            trails.array[i] = trail
            trail.objectWillChange.send()
            self.objectWillChange.send()
        }
        self.persist(gpx: trail.gpx)
    }
    
    func remove(id: UUID) {
        let file = "trails/\(id).json"
        let filename = documentsDirectory.appendingPathComponent(file)
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
        let urls = try? FileManager.default.contentsOfDirectory(at: documentsDirectory.appendingPathComponent("trails"), includingPropertiesForKeys: nil).filter { $0.pathExtension == "json" }
        let trails = urls?.compactMap { url -> Trail? in
            do {
                let data = try Data(contentsOf: url)
                let gpx = try JSONDecoder().decode(Gpx.self, from: data)
                return Trail(gpx: gpx)
            } catch {
                switch error {
                case DecodingError.keyNotFound(let key, let context): print("􀈾 Trail decodding error = \(error.localizedDescription), key not found = \(key), context = \(context)")
                default: print("􀈾 Trail decodding error = \(error.localizedDescription)")
                }
                return nil
            }
        }
        self.trails.array = trails ?? []
    }
        
    func addMissingDepartment(trail: Trail) {
        Task(priority: .background) {
            guard trail.department == nil, let loc = trail.locations.last?.clLocation else { return }
            LocationManager.shared.getDepartment(location: loc) { department in
                trail.department = department
            }
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
    
    private func persist(gpx: Gpx) {
        let file = "trails/\(gpx.id).json"
        let filename = documentsDirectory.appendingPathComponent(file)
        do {
            let data = try JSONEncoder().encode(gpx)
            try data.write(to: filename)
        } catch {
            print("􀌓 Trail persistLocallyError = \(error)")
        }
    }
    
}
