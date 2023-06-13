//
//  UserDefaults.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 13/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation

let defaultAverageSpeed: Double = 1.111 // m.s-1 == 4km.h-1

extension UserDefaults {
    
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
}
