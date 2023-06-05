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
import SwiftUI
import Accelerate

class Gpx: Codable, Identifiable {
    
    init(name: String = "test", locations: [Location] = [mockLoc1], date: Date? = Date(), department: String? = nil, isFav: Bool? = false, isDisplayed: Bool? = false, color: Int? = Int.random(in: 0...15), lineWidth: CGFloat? = 3, distance: CLLocationDistance? = nil, elevationGain: CLLocationDistance? = nil) {
        self.id = UUID()
        self.name = name
        self.locations = locations
        self.date = date
        self.department = department
        self.isFav = isFav
        self.isDisplayed = isDisplayed
        self.color = color
        self.lineWidth = lineWidth
        self.distance = distance
        self.elevationGain = elevationGain
    }
    
    var id: UUID
    var name: String
    var locations: [Location]
    var date: Date?
    var department: String?
    var isFav: Bool?
    var isDisplayed: Bool?
    var color: Int?
    var lineWidth: CGFloat?
    var distance: CLLocationDistance?
    var elevationGain: CLLocationDistance?
    
}

class Trail: Identifiable, ObservableObject {
    
    init(gpx: Gpx = Gpx()) {
        self.gpx = gpx
        self.name = gpx.name
        self.department = gpx.department
        self.isFav = gpx.isFav ?? false
        self.isDisplayed = gpx.isDisplayed ?? false
        self.color = (gpx.color ?? 0).color
        self.lineWidth = gpx.lineWidth ?? 3
    }
    
    // Decodable properties
    var gpx: Gpx
    
    // Computed properties
    var id: UUID { gpx.id }
    var locations: [Location] { gpx.locations }
    var date: Date { gpx.date ?? Date(timeIntervalSince1970: 0) }
    
    enum DownloadState: Equatable {
        case unknown, notDownloaded, downloading, downloaded
    }
    
    @Published var downloadState: DownloadState = .unknown
    
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
    
    @Published var isFav: Bool {
        didSet {
            gpx.isFav = isFav
        }
    }
    
    @Published var isDisplayed: Bool {
        didSet {
            gpx.isDisplayed = isDisplayed
        }
    }
    
    @Published var color: Color {
        didSet {
            gpx.color = color.code
        }
    }
    
    @Published var lineWidth: CGFloat {
        didSet {
            gpx.lineWidth = lineWidth
        }
    }
    
    /// Replace black in darkMode and white in lightMode by gray color to be able to see them
    var colorHandlingLightAndDarkMode: Color {
        let style = UIApplication.shared.keyWindow?.traitCollection.userInterfaceStyle
        if let style, style == .dark && color == .black || style == .light && color == .white {
            return .gray
        } else {
            return color
        }
    }
    
    /// Replace black by white and white by black
    var checkMarkColorHandlingBlackAndWhite: Color {
        if color == .white {
            return .black
        } else {
            return .white
        }
    }
    
    var polyline: Polyline {
        let polyline = Polyline(coordinates: locations.map { $0.clLocation.coordinate }, count: locations.count)
        polyline.color = color.uiColor
        polyline.id = id
        polyline.lineWidth = lineWidth
        return polyline
    }
    
    var boundingBox: MKMapRect {
        self.polyline.boundingMapRect
    }
    
    var distance: CLLocationDistance {
        if let distance =  gpx.distance { return distance }// Optimization if we import a Gpx (GPXKit already compute it so inside the JSON file)
        guard !locations.isEmpty else { return .nan }
        let distance = locations.reduce((0, locations[0].clLocation)) { (accumulation, nextValue) -> (CLLocationDistance, CLLocation) in
            let delta =  nextValue.clLocation.distance(from: accumulation.1)
            return (accumulation.0 + delta, nextValue.clLocation)
        }.0
        gpx.distance = distance
        return distance
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
        elevations.enumerated().forEach{ (index, alt) in
            guard index % (elevations.count / size) == 0 else { return }
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
        altitudes.forEach {
            guard abs($0 - lastAltitude) > threshold else { return }
            circularBuffer.append($0)
            filteredBuffer.append(circularBuffer.average)
            lastAltitude = circularBuffer.average
        }
        return filteredBuffer
    }
    
    var hasElevationData: Bool { elevationGain > 0 }
    
    var elevationGain: CLLocationDistance {
        if let elevationGain =  gpx.elevationGain { return elevationGain }// Optimization if we import a Gpx
        guard !elevations.isEmpty else { return .nan }
        let elevationGain = elevations.reduce((0, elevations[0])) { (accumulation, nextValue) -> (CLLocationDistance, CLLocationDistance) in
            var delta =  nextValue - accumulation.1
            delta = delta > 0 ? delta : 0
            return (accumulation.0 + delta, nextValue)
        }.0
        gpx.elevationGain = elevationGain
        return elevationGain
    }
    
    var elevationLoss: CLLocationDistance {
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
        let totalDistance = distance + 10 * elevationGain
        let duration = totalDistance/speed
        return duration.toDurationString
    }
        
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
    
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
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

class Polyline: MKPolyline {
    
    var color: UIColor?
    var id: UUID?
    var lineWidth: CGFloat?
    
    func isEqual(polyline: Polyline) -> Bool {
        guard let id1 = self.id, let id2 = polyline.id, let color1 = self.color, let color2 = polyline.color, let lineWidth1 = self.lineWidth, let lineWidth2 = polyline.lineWidth else { return false }
        return id1 == id2 && color1 == color2 && lineWidth1 == lineWidth2
    }
    
}

struct CircularBuffer {
    
    var size: Int
    var values = [Double]()
    var average: Double { vDSP.mean(values) }
    
    init(size: Int) {
        self.size = size
    }
    
    mutating func append(_ value: Double) {
        values.append(value)
        if values.count > size {
            values.removeFirst()
        }
    }
}


func printTimeElapsedWhenRunningCode(title:String, operation:()->()) {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("Time elapsed for \(title): \(timeElapsed) s.")
}
