//
//  Collection.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 01/09/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation

struct CollectedPoi: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    let poi: Poi
    var date: Date
    var description: String?
    var photosURL: [URL?]?
    
    mutating func editDate(newDate: Date) {
        self.date = newDate
    }
}
