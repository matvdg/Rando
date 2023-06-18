//
//  String.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 10/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation

extension String {
    
    var localized: String { NSLocalizedString(self, comment: self) }
    
    var altitude: Double? {
        guard let rangeFrom = range(of: "<ele>")?.upperBound, let rangeTo = self[rangeFrom...].range(of: "</ele>")?.lowerBound else { return nil }
        return Double(String(self[rangeFrom..<rangeTo]))
    }
    
    var latitude: Double? {
        guard let rangeFrom = range(of: "<trkpt lat=\"")?.upperBound, let rangeTo = self[rangeFrom...].range(of: "\"")?.lowerBound else { return nil }
        return Double(String(self[rangeFrom..<rangeTo]))
    }
    
    var longitude: Double? {
        guard let rangeFrom = range(of: "lon=\"")?.upperBound, let rangeTo = self[rangeFrom...].range(of: "\"")?.lowerBound else { return nil }
        return Double(String(self[rangeFrom..<rangeTo]))
    }
    
    var name: String {
        var clean = self
        clean = clean.replacingOccurrences(of: ".gpx", with: "")
        clean = clean.replacingOccurrences(of: "-", with: " ")
        clean = clean.replacingOccurrences(of: "_", with: " ")
        return clean.capitalized
    }
    
    var cleanHtmlString: String {
        guard let data = self.data(using: .utf8) else {
            return ""
        }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return ""
        }
        return attributedString.string.replacingOccurrences(of: "\\", with: "")
    }
}
