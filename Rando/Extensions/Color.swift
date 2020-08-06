//
//  Color.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 10/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import UIKit

extension Color {
    
    static var grgreen: Color { Color("grgreen") }
    static var grblue: Color { Color("grblue") }
    static var tintColor: Color { Color("tintColor") }
    static var text: Color { Color("text") }
    static var grgray: Color { Color("grgray") }
    static var lightgray: Color { Color("lightgray") }
    static var lightgrayInverted: Color { Color("lightgrayInverted") }
    static var alpha: Color { Color("alpha") }
    
    var code: Int {
        switch self {
        case .grblue: return 0
        case .grgreen: return 1
        case .red: return 2
        case .pink: return 3
        case .black: return 4
        case .white: return 5
        case .purple: return 6
        case .gray: return 7
        default: return 8
        }
    }
    
    var uiColor: UIColor {
        switch self {
        case .grblue: return .grblue
        case .grgreen: return .grgreen
        case .red: return .red
        case .pink: return .systemPink
        case .black: return .black
        case .white: return .white
        case .purple: return .purple
        case .gray: return .gray
        default: return .yellow
        }
    }
    
}

extension Int {
    var color: Color {
        switch self {
        case 0: return .grblue
        case 1: return .grgreen
        case 2: return .red
        case 3: return .pink
        case 4: return .black
        case 5: return .white
        case 6: return .purple
        case 7: return .gray
        default: return .yellow
        }
    }
}

extension UIColor {
    
    static var grgreen: UIColor { UIColor(named: "grgreen")! }
    static var grblue: UIColor { UIColor(named: "grblue")! }
    static var grgray: UIColor { UIColor(named: "grgray")! }
    static var alpha: UIColor { UIColor(named: "alpha")! }
    
}
