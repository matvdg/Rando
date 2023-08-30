//
//  Poi.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import UIKit
import CoreLocation

struct Poi: Decodable, Identifiable {
    
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
    var photo: String?
    
    init(lat: CLLocationDegrees, lng: CLLocationDegrees, alt: CLLocationDistance) {
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
        case photo
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
        photo = try? container.decode(String.self, forKey: .photo)
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
    var phoneNumber: URL? {
        guard let number = phone else { return nil }
        let cleaned = number.components(separatedBy: " ").joined()
        return URL(string: "tel://\(cleaned)")
    }
    var hasWebsite: Bool { url != nil }
    var hasPhoneNumber: Bool { phoneNumber != nil }
    
    enum Category: String, Decodable, CaseIterable {
        case refuge, waterfall, spring, step, peak, pov, pass, parking, lake, dam, camping, bridge, shop, cabin, sheld
    }
}
