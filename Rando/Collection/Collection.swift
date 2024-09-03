//
//  Collection.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 01/09/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation

struct Collection: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    let poi: Poi
    let date: Date
}
