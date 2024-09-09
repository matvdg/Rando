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
    
    /// For Collection & TrailsView
    @Published var selectedCategory: Category = UserDefaults.selectedCategory {
        willSet {
            UserDefaults.selectedCategory = newValue
        }
    }
    
    // For MapView
    @Published var displayedCategory: Category = UserDefaults.displayedCategory {
        willSet {
            UserDefaults.displayedCategory = newValue
        }
    }
    
    
    @Published var selectedTracking: Tracking = UserDefaults.currentTracking {
        willSet {
            UserDefaults.currentTracking = newValue
        }
    }
    
    @Published var isMapFullScreen: Bool = false
    
    @Published var hasSearchDataInCloud: Bool = UserDefaults.hasSearchDataInCloud {
        willSet {
            UserDefaults.hasSearchDataInCloud = newValue
        }
    }
}
