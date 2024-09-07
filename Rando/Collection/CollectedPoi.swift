//
//  Collection.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 01/09/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import SwiftUI

class CollectedPoi: Codable, Identifiable, ObservableObject, Equatable, Hashable {
    
    static func == (lhs: CollectedPoi, rhs: CollectedPoi) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: UUID
    let poi: Poi
    var date: Date
    var notes: String?
    var photosUrl: [String]?
    
    init(poi: Poi, date: Date) {
        self.id = UUID()
        self.poi = poi
        self.date = date
    }
}
