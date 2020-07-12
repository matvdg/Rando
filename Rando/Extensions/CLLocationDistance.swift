//
//  CLLocationDistance.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 13/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationDistance {
    
    /// Convert CLLocationDistance (meters) to String using formatter (Locale is considered)
    var toString: String {
        guard !self.isNaN else { return "_" }
        let formatter = MeasurementFormatter()
        let measurement = Measurement(value: Double(Int(self)), unit: UnitLength.meters)
        formatter.unitStyle = .short
        if self < 1 {
            formatter.unitOptions = .providedUnit
        } else {
            formatter.unitOptions = .naturalScale
        }
        formatter.numberFormatter.usesSignificantDigits = true
        formatter.numberFormatter.maximumSignificantDigits = 3
        return formatter.string(from: measurement)
    }
    
    var toStringMeters: String {
        guard !self.isNaN else { return "_" }
        let formatter = MeasurementFormatter()
        let measurement = Measurement(value: Double(Int(self)), unit: UnitLength.meters)
        formatter.unitStyle = .short
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.usesSignificantDigits = true
        formatter.numberFormatter.maximumSignificantDigits = 3
        return formatter.string(from: measurement)
    }
    
    
    
}
