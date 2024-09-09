//
//  UserDefaults.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 13/07/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation

let defaultAverageSpeed: Double = 1.111 // m.s-1 == 4km.h-1

extension UserDefaults {
    
    static var hasSearchDataInCloud: Bool {
        get {
            let value = UserDefaults.standard.bool(forKey: "hasSearchDataInCloud")
            UserDefaults.standard.set(true, forKey: "hasSearchDataInCloud")
            return value
        } set {
            UserDefaults.standard.set(newValue, forKey: "hasSearchDataInCloud")
        }
    }
    
    static var averageSpeed: Double {
        get {
            let value = UserDefaults.standard.double(forKey: "averageSpeed")
            return value == 0 ? defaultAverageSpeed : value
        } set {
            UserDefaults.standard.set(newValue, forKey: "averageSpeed")
        }
    }
    
    static var hasBeenLaunched: Bool {
        get {
            let result = UserDefaults.standard.bool(forKey: "hasBeenLaunched")
            UserDefaults.standard.set(true, forKey: "hasBeenLaunched")
            return result
        } set {
            UserDefaults.standard.set(newValue, forKey: "hasBeenLaunched")
        }
    }
    
    static var isOffline: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isOffline")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isOffline")
        }
    }
    
    static var currentLayer: Layer {
        get {
            Layer(rawValue: UserDefaults.standard.string(forKey: "layer") ?? "ign25") ?? .ign25
        }
        set {
            guard newValue != self.currentLayer else { return }
            UserDefaults.standard.set(newValue.rawValue, forKey: "layer")
            print("􀯮 Layer has been set to \(newValue)")
        }
    }
    
    static var currentTracking: Tracking {
        get {
            Tracking(rawValue: UserDefaults.standard.string(forKey: "currentTracking") ?? "bounding") ?? .bounding
        }
        set {
            guard newValue != self.currentTracking else { return }
            UserDefaults.standard.set(newValue.rawValue, forKey: "currentTracking")
            print("􀯮 Current Tracking has been set to \(newValue)")
        }
    }
    
    static var selectedCategory: Category {
        get {
            Category(rawValue: UserDefaults.standard.string(forKey: "selectedCategory") ?? "all") ?? .all
        }
        set {
            guard newValue != self.selectedCategory else { return }
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedCategory")
            print("􀯮 Selected category has been set to \(newValue)")
        }
    }
    
    static var displayedCategory: Category {
        get {
            Category(rawValue: UserDefaults.standard.string(forKey: "displayedCategory") ?? "all") ?? .all
        }
        set {
            guard newValue != self.displayedCategory else { return }
            UserDefaults.standard.set(newValue.rawValue, forKey: "displayedCategory")
            print("􀯮 Displayed category has been set to \(newValue)")
        }
    }
    
    
}
