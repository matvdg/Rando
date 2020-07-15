//
//  UserDefaults.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 13/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static var hasBeenLaunched: Bool {
        get {
            let result = UserDefaults.standard.bool(forKey: "hasBeenLaunched")
            UserDefaults.standard.set(true, forKey: "hasBeenLaunched")
            return result
        } set {
            UserDefaults.standard.set(newValue, forKey: "hasBeenLaunched")
        }
    }
    
    static var currentTrail: String? {
        get {
            UserDefaults.standard.string(forKey: "currentTrail") ?? nil
        } set {
            UserDefaults.standard.set(newValue, forKey: "currentTrail")
        }
    }
}
