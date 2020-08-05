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
    
    init(name: String = "test", locations: [Location] = [mockLoc1], date: Date? = Date(), department: String? = nil, isFav: Bool? = false) {
        self.id = UUID()
        self.name = name
        self.locations = locations
        self.date = date
        self.department = department
        self.isFav = isFav
    }
    
    // Decodable properties
    var id: UUID
    var name: String
    var locations: [Location]
    var date: Date?
    var department: String?
    var isFav: Bool?
    
    
}

class Trail: Identifiable, ObservableObject {
    
    init(gpx: Gpx = Gpx()) {
        self.gpx = gpx
        self.name = gpx.name
        self.department = gpx.department
        self.isFav = gpx.isFav
    }
    
    // Decodable properties
    var gpx: Gpx
    
    // Computed properties
    var id: UUID { gpx.id }
    var isFavorite: Bool { gpx.isFav ?? false }
    var locations: [Location] { gpx.locations }
    var date: Date { gpx.date ?? Date(timeIntervalSince1970: 0) }
    
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
    
    @Published var isFav: Bool? {
        didSet {
            gpx.isFav = isFav
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
    
    var firstLocation: CLLocationCoordinate2D {
        locations.first?.clLocation.coordinate ?? CLLocationCoordinate2D()
    }
    
    lazy var elevations: [CLLocationDistance] = computeFilteredElevations()
    
    /// Max 100 elevations for chart
    var simplifiedElevations: [CLLocationDistance] {
        let size = 100
        guard elevations.count > size else { return elevations }
        var simplifiedElevations = [CLLocationDistance]()
        for (i, alt) in elevations.enumerated() {
            guard i % (elevations.count / size) == 0 else { continue }
            simplifiedElevations.append(alt)
        }
        return simplifiedElevations
    }
    
    func computeFilteredElevations() -> [CLLocationDistance] {
        let size = 5
        let threshold: CLLocationDistance = 7
        guard var lastAltitude = locations.first?.altitude else { return [] }
        var filteredBuffer = [CLLocationDistance]()
        var circularBuffer = CircularBuffer(size: size)
        circularBuffer.append(lastAltitude)
        filteredBuffer.append(circularBuffer.average)
        let altitudes = locations.compactMap { $0.altitude }
        for altitude in altitudes {
            guard abs(altitude - lastAltitude) > threshold else { continue }
            circularBuffer.append(altitude)
            filteredBuffer.append(circularBuffer.average)
            lastAltitude = circularBuffer.average
        }
        return filteredBuffer
    }
    
    var positiveElevation: CLLocationDistance {
        guard !elevations.isEmpty else { return .nan }
        return elevations.reduce((0, elevations[0])) { (accumulation, nextValue) -> (CLLocationDistance, CLLocationDistance) in
            var delta =  nextValue - accumulation.1
            delta = delta > 0 ? delta : 0
            return (accumulation.0 + delta, nextValue)
        }.0
    }
    
    var negativeElevation: CLLocationDistance {
        guard !elevations.isEmpty else { return .nan }
        return elevations.reduce((0, elevations[0])) { (accumulation, nextValue) -> (CLLocationDistance, CLLocationDistance) in
            var delta =  nextValue - accumulation.1
            delta = delta < 0 ? abs(delta) : 0
            return (accumulation.0 + delta, nextValue)
        }.0
    }
    
    var minAlt: CLLocationDistance {
        guard !elevations.isEmpty else { return .nan }
        let min = elevations.reduce(elevations[0]) { (accumulation, nextValue) -> CLLocationDistance in
            nextValue < accumulation ? nextValue : accumulation
        }
        return min < 0 ? 0 : min
    }
    
    var maxAlt: CLLocationDistance {
        guard !elevations.isEmpty else { return .nan }
        return elevations.reduce(elevations[0]) { (accumulation, nextValue) -> CLLocationDistance in
            nextValue > accumulation ? nextValue : accumulation
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
    
    var locationsPreview: [CGPoint] {
        let frame = CGRect(origin: .zero, size: CGSize(width: 80, height: 80))
        let view = UIView(frame: frame)
        let mapView = MKMapView(frame: frame)
        var region = MKCoordinateRegion(polyline.boundingMapRect)
        region.span.latitudeDelta += 0.01
        region.span.longitudeDelta += 0.01
        mapView.region = region
        let mapPoints = polyline.points()
        var points = [CGPoint]()
        let max = polyline.pointCount - 1
        for i in 0...max {
           let coordinate = mapPoints[i].coordinate
           points.append(mapView.convert(coordinate, toPointTo: view))
        }
        return points
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
