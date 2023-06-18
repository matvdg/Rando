//
//  Date.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 01/06/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import Foundation

extension Date {
    
    var toString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        if Calendar.current.isDateInToday(self) {
            return "\("Today".localized) \("at".localized) \(dateFormatter.string(from: self))"
        } else if Calendar.current.isDateInYesterday(self) {
            return "\("Yesterday".localized) \("at".localized) \(dateFormatter.string(from: self))"
        } else {
            let time = dateFormatter.string(from: self)
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            let date = dateFormatter.string(from: self)
            return "\(date) \("at".localized) \(time)"
        }
    }
  
    
}
