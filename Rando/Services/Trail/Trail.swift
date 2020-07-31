//
//  Trail.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 06/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class Gpx: Codable, Identifiable {
    
    init(name: String = "test", locations: [Location] = [mockLoc1], date: Date? = Date(), department: String? = nil) {
        self.id = UUID()
        self.name = name
        self.locations = locations
        self.date = date
        self.department = department
    }
    
    // Decodable properties
    var id: UUID
    var name: String
    var locations: [Location]
    var date: Date?
    var department: String?
    
    
}

class Trail: Identifiable, ObservableObject {
        
    init(gpx: Gpx = Gpx()) {
        self.gpx = gpx
        self.name = gpx.name
        self.department = gpx.department
    }
    
    // Decodable properties
    var gpx: Gpx
    
    // Computed properties
    var id: UUID { gpx.id }
    var locations: [Location] { gpx.locations }
    var date: Date { gpx.date ?? Date() }
    
    @Published var name: String {
        didSet {
            gpx.name = name
        }
    }
    
    @Published var department: String? {
        didSet {
            gpx.department = department
        }
    }
    
    var polyline: MKPolyline {
        MKPolyline(coordinates: locations.map { $0.clLocation.coordinate }, count: locations.count)
    }
    
    var distance: CLLocationDistance {
        guard !locations.isEmpty else { return .nan }
        return locations.reduce((0, locations[0].clLocation)) { (accumulation, nextValue) -> (CLLocationDistance, CLLocation) in
            let delta =  nextValue.clLocation.distance(from: accumulation.1)
            return (accumulation.0 + delta, nextValue.clLocation)
        }.0
    }
    
    var positiveElevation: CLLocationDistance {
        guard !locations.isEmpty else { return .nan }
        return locations.reduce((0, locations[0].altitude)) { (accumulation, nextValue) -> (CLLocationDistance, CLLocationDistance) in
            var delta =  nextValue.altitude - accumulation.1
            delta = delta > 0 ? delta : 0
            return (accumulation.0 + delta, nextValue.altitude)
        }.0
    }
    
    var negativeElevation: CLLocationDistance {
        guard !locations.isEmpty else { return .nan }
        return locations.reduce((0, locations[0].altitude)) { (accumulation, nextValue) -> (CLLocationDistance, CLLocationDistance) in
            var delta =  nextValue.altitude - accumulation.1
            delta = delta < 0 ? abs(delta) : 0
            return (accumulation.0 + delta, nextValue.altitude)
        }.0
    }
    
    var minAlt: CLLocationDistance {
        guard !locations.isEmpty else { return .nan }
        return locations.reduce(locations[0].altitude) { (accumulation, nextValue) -> CLLocationDistance in
            nextValue.altitude < accumulation ? nextValue.altitude : accumulation
        }
    }
    
    var maxAlt: CLLocationDistance {
        guard !locations.isEmpty else { return .nan }
        return locations.reduce(locations[0].altitude) { (accumulation, nextValue) -> CLLocationDistance in
            nextValue.altitude > accumulation ? nextValue.altitude : accumulation
        }
    }
    
    var estimatedTime: String {
        let speed: CLLocationSpeed = 1.111 // 4Km.h-1
        let totalDistance = distance + 10 * positiveElevation
        let duration = totalDistance/speed
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
    
    var displayed: Bool { UserDefaults.currentTrail == self.id.uuidString }
    
    var elevations: [CLLocationDistance] {
        var simplified = [CLLocationDistance]()
        let elevations =  locations.map { $0.altitude }
        for (i, alt) in elevations.enumerated() {
            guard i % 10 == 0 else { continue }
            simplified.append(alt)
        }
        return simplified
    }
}


public struct Location: Codable {
    
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var altitude: CLLocationDistance
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, altitude: CLLocationDistance) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
    }
    
    var clLocation: CLLocation {
        CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Location.self.CodingKeys.self)
        
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        let altitude = try container.decode(CLLocationDistance.self, forKey: .altitude)
        
        self.init(latitude: latitude, longitude: longitude, altitude: altitude)
    }
}
