//
//  String.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 10/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation

extension String {
    
    var localized: String { NSLocalizedString(self, comment: self) }
    
    var separateStrings: [String] {
        self.components(separatedBy: CharacterSet(charactersIn: "-_ "))
    }
    
    var withoutAccents: String {
        self.folding(options: .diacriticInsensitive, locale: .current)
            .replacingOccurrences(of: "ß", with: "ss")
    }
    
    var withoutNumber: Bool {
        Double(self) == nil
    }
    
    var withUppercasedOnly: Bool {
        self.first?.isUppercase == true
    }
    
    var withMoreThanTwoLetters: Bool {
        self.count > 2
    }
    
    var withoutAnyDigits: Bool {
        self.rangeOfCharacter(from: .decimalDigits) == nil
    }
    
    var withoutPunctuation: String {
        self.components(separatedBy: CharacterSet.punctuationCharacters).joined()
    }
        
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
