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
import CoreGPX

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
        var departments = ["all"]
        departments.append(contentsOf: trails.array.compactMap { $0.department }.removingDuplicates() )
        return departments
    }
    
    var cancellables = [AnyCancellable]()
    
    init() {
        getTrails()
    }
    
    // MARK: - Public methods
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
            let name = gpx?.metadata?.name ?? gpx?.tracks.first?.name ?? url.lastPathComponent
            return Trail(gpx: Gpx(name: name, locations: locations))
        }
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
                self.save(trail: trail)
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