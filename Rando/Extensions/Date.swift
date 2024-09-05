//
//  Date.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 01/06/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation

extension Date {
    
    /// Aujourd'hui à 18h33
    var toString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        if Calendar.current.isDateInToday(self) {
            return "\("today".localized) \("at".localized) \(dateFormatter.string(from: self))"
        } else if Calendar.current.isDateInYesterday(self) {
            return "\("yesterday".localized) \("at".localized) \(dateFormatter.string(from: self))"
        } else {
            let time = dateFormatter.string(from: self)
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            let date = dateFormatter.string(from: self)
            return "\(date) \("at".localized) \(time)"
        }
    }
    
    /// 18/11/2023 à 18h33
    var toStringAbsolute: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let time = dateFormatter.string(from: self)
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let date = dateFormatter.string(from: self)
        return "\(date) \("at".localized) \(time)"
    }
    
    
}
