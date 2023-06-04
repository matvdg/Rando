//
//  Double.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 15/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation

extension Double {
    
    var toBytes: String {
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
    
}
