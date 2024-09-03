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
import CoreTransferable
import UniformTypeIdentifiers

let lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
let defaultLineWidth: CGFloat = 4

class Gpx: Codable, Identifiable {

    init(name: String = "test", description: String = lorem, locations: [Location] = [mockLoc1], date: Date? = Date(), department: String? = nil, isFav: Bool? = false, isDisplayed: Bool? = false, color: String? = CGColor.randomColor.hexaCode, lineWidth: CGFloat? = defaultLineWidth, distance: CLLocationDistance? = nil, elevationGain: CLLocationDistance? = nil) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.locations = locations
        self.date = date
        self.department = department
        self.isFav = isFav
        self.isDisplayed = isDisplayed
        self.hexaColor = color
        self.lineWidth = lineWidth
        self.distance = distance
        self.elevationGain = elevationGain
    }
    
    var id: UUID
    var description: String?
    var name: String
    var locations: [Location]
    var date: Date?
    var department: String?
    var isFav: Bool?
    var isDisplayed: Bool?
    var hexaColor: String?
    var lineWidth: CGFloat?
    var distance: CLLocationDistance?
    var elevationGain: CLLocationDistance?
    
}

class Trail: Identifiable, ObservableObject {
    
    init(gpx: Gpx = Gpx()) {
        self.gpx = gpx
        self.name = gpx.name
        self.description = gpx.description ?? ""
        self.department = gpx.department
        self.isFav = gpx.isFav ?? false
        self.isDisplayed = gpx.isDisplayed ?? false
        self.color = (gpx.hexaColor ?? "").hexToColor
        self.lineWidth = gpx.lineWidth ?? defaultLineWidth
    }
    
    // Decodable properties
    var gpx: Gpx
    
    var difficulty: Difficulty {
        if hasElevationData {
            switch elevationGain {
            case 0..<200: return .beginner
            case 200..<500: return .easy
            case 500..<1000: return .medium
            case 1000..<1500: return .hard
            default: return .extreme
            }
        } else {
            switch distance {
            case 0..<5: return .beginner
            case 5..<10: return .easy
            case 10..<15: return .medium
            case 15..<20: return .hard
            default: return .extreme
            }
        }
    }
    
    var isLoop: Bool {
        if let lastLoc = locations.last?.clLocation.coordinate, firstLocation.distance(from: lastLoc) < 100 {
            return true
        } else {
            return false
        }
    }
    
    // Computed properties
    var id: UUID { gpx.id }
    var locations: [Location] { gpx.locations }
    var date: Date { gpx.date ?? Date(timeIntervalSince1970: 0) }
    
    enum DownloadState: Equatable {
        case unknown, notDownloaded, downloading, downloaded
    }
    
    enum Difficulty: String {
        case beginner, easy, medium, hard, extreme
    }
    
    @Published var downloadState: DownloadState = .unknown
    
    @Published var name: String {
        didSet {
            gpx.name = name
        }
    }
    
    @Published var description: String {
        didSet {
            gpx.description = description
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
    
    @Published var color: CGColor {
        didSet {
            gpx.hexaColor = color.hexaCode
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
        if let style, style == .dark && color == UIColor.black.cgColor || style == .light && color == UIColor.white.cgColor {
            return Color.gray
        } else {
            return Color(UIColor(cgColor: color))
        }
    }
    
    var polyline: Polyline {
        let polyline = Polyline(coordinates: locations.map { $0.clLocation.coordinate }, count: locations.count)
        polyline.color = UIColor(cgColor: color)
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
    
    lazy var elevations: [CLLocationDistance] = locations.map { $0.altitude ?? 0 }
    //computeFilteredElevations()
    
    lazy var graphElevations: [GraphData] =  {
        elevations.enumerated().map { GraphData(index: $0, elevation: $1 )}
    }()

    
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
    
    var minAlt: CLLocationDistance { elevations.min() ?? .nan }
    
    var maxAlt: CLLocationDistance { elevations.max() ?? .nan }
    
    var estimatedTime: String {
        let speed: CLLocationSpeed = UserDefaults.averageSpeed // 4Km.h-1
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
    var altitude: CLLocationDistance?
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, altitude: CLLocationDistance?) {
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
        CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), altitude: altitude ?? 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
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

struct GraphData: Identifiable {
    let id = UUID()
    let index: Int
    let elevation: CLLocationDistance
}
