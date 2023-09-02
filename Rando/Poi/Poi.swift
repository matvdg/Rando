//
//  Poi.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import UIKit
import SwiftUI
import CoreLocation

struct Poi: Codable, Identifiable, Equatable, Hashable {
    
    var id: UUID
    
    // Decodable properties
    var name: String
    var category: Category
    var lat: CLLocationDegrees
    var lng: CLLocationDegrees
    var alt: CLLocationDistance?
    // Optional
    var phone: String?
    var description: String?
    var url: String?
    var photoUrl: String?
    
    init(lat: CLLocationDegrees = 0, lng: CLLocationDegrees = 0, alt: CLLocationDistance = 0) {
        self.name = "Pin"
        self.category = .step
        self.lat = lat
        self.lng = lng
        self.alt = alt
        self.id = UUID()
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case category
        case lat
        case lng
        case alt
        case phone
        case description
        case url
        case photoUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID()
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(Category.self, forKey: .category)
        lat = try container.decode(CLLocationDegrees.self, forKey: .lat)
        lng = try container.decode(CLLocationDegrees.self, forKey: .lng)
        alt = try? container.decode(CLLocationDistance.self, forKey: .alt)
        phone = try? container.decode(String.self, forKey: .phone)
        description = try? container.decode(String.self, forKey: .description)
        url = try? container.decode(String.self, forKey: .url)
        photoUrl = try? container.decode(String.self, forKey: .photoUrl)
    }
    
    // Computed properties
    var coordinate: Location { Location(latitude: lat, longitude: lng, altitude: alt ?? 0) }
    var pseudoTrail: Trail { Trail(gpx: Gpx(name: "pseudoTrailForPoi", locations: [self.coordinate]))}
    var altitudeInMeters: String {
        if let alt {
            return "\(Int(alt))m"
        } else {
            return "_"
        }
    }
    var website: URL? {
        guard let url else { return nil }
        return URL(string: "http://\(url)")
    }
        
    var image: Image? {
        if let photoUrl, let url = URL(string: photoUrl) {
            let fileUrl = FileManager.documentsDirectory.appendingPathComponent("pictures").appendingPathComponent(url.lastPathComponent)
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                do {
                    let data = try Data(contentsOf: fileUrl)
                    if let uiImage = UIImage(data: data) {
                        return Image(uiImage: uiImage)
                    } else {
                        return nil
                    }
                } catch {
                    print(error)
                    return nil
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    var icon: Image {
        switch category {
        case .camping: return Image(systemName: "tent")
        case .parking: return Image(systemName: "car")
        case .peak, .pass: return Image(systemName: "mountain.2")
        case .pov: return Image(systemName: "eye")
        case .waterfall, .lake, .dam, .bridge: return Image(systemName: "camera")
        case .refuge: return Image(systemName: "house.lodge")
        case .shelter: return Image(systemName: "house")
        case .shop: return Image(systemName: "basket")
        case .spring: return Image(systemName: "drop")
        default: return Image(systemName: "mappin")
        }
    }
    
    func loadImageFromURL() async throws -> Image? {
        guard let photoUrl, let url = URL(string: photoUrl) else {
            return nil
        }
        let fileUrl = FileManager.documentsDirectory.appendingPathComponent("pictures").appendingPathComponent(url.lastPathComponent)
        guard !FileManager.default.fileExists(atPath: fileUrl.path) else {
            return nil
        } // Prevent redownloading already downloaded picture
        let response = try await URLSession.shared.data(from: url)
        if let uiImage = UIImage(data: response.0) {
            try? FileManager.default.createDirectory(at: FileManager.documentsDirectory.appendingPathComponent("pictures"), withIntermediateDirectories: true, attributes: [:])
            let file = "pictures/\(url.lastPathComponent)"
            let filename = FileManager.documentsDirectory.appendingPathComponent(file)
            try response.0.write(to: filename)
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
    }
    
    var phoneNumber: URL? {
        guard let number = phone else { return nil }
        let cleaned = number.components(separatedBy: " ").joined()
        return URL(string: "tel://\(cleaned)")
    }
    var hasWebsite: Bool { url != nil }
    var hasPhoneNumber: Bool { phoneNumber != nil }
    
    enum Category: String, Codable, CaseIterable {
        case refuge, waterfall, spring, step, peak, pov, pass, parking, lake, dam, camping, bridge, shop, shelter
    }
    
    func isAlreadyCollected(userPosition: CLLocation) -> Bool {
        let isAlreadyCollected = CollectionManager.shared.collection.contains {
            $0.poi.name == self.name
        }
        guard !isAlreadyCollected else {
            return true
        }
        if self.category == .shop {
            return true
        }
        if self.coordinate.clLocation.distance(from: userPosition) < 1000 {
            return false
        } else {
            return true
        }
    }
}
