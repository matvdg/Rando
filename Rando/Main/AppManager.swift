//
//  AppManager.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 29/08/2024.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation

class AppManager: ObservableObject {
    
    static var shared: AppManager = AppManager()
    
    @Published var selectedLayer: Layer = UserDefaults.currentLayer {
        willSet {
            UserDefaults.currentLayer = newValue
        }
    }
    @Published var selectedCategory: Category = UserDefaults.currentCategory {
        willSet {
            UserDefaults.currentCategory = newValue
        }
    }
    
    
    @Published var selectedTracking: Tracking = UserDefaults.currentTracking {
        willSet {
            UserDefaults.currentTracking = newValue
        }
    }
    
    @Published var isLocked: Bool = false
}