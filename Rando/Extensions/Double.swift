//
//  Double.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 15/07/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation

extension Double {
    
    var toBytesString: String {
        let formatter = MeasurementFormatter()
        let measurement = Measurement(value: self, unit: UnitInformationStorage.bytes)
        formatter.unitStyle = .short
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter.string(from: measurement.converted(to: .megabytes))
    }
    
    var toDurationString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: self) ?? ""
    }
    
    var toSpeedString: String {
        let measurement = Measurement(value: self, unit: UnitSpeed.metersPerSecond)
        
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitStyle = .medium
        measurementFormatter.numberFormatter.maximumFractionDigits = 1
        let formattedSpeed = measurementFormatter.string(from: measurement)
        return formattedSpeed
    }
    
}
