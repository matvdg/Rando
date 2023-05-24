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
    static var tintColorTabBar: Color { Color("tintColorTabBar") }
    static var text: Color { Color("text") }
    static var grgray: Color { Color("grgray") }
    static var lightgray: Color { Color("lightgray") }
    static var lightgrayInverted: Color { Color("lightgrayInverted") }
    static var alpha: Color { Color("alpha") }
    static var background: Color { Color("background") }
    
    var code: Int {
        /*[.grblue, .grgreen, .red],
         [.orange, .black, .white],
         [.purple, .gray, .yellow],
         [.green, .blue, .cyan],
         [.brown, .indigo, .pink]*/
        switch self {
        case .grblue: return 0
        case .grgreen: return 1
        case .red: return 2
        case .orange: return 3
        case .black: return 4
        case .white: return 5
        case .purple: return 6
        case .gray: return 7
        case .yellow: return 8
        case .green: return 9
        case .blue: return 10
        case .cyan: return 11
        case .brown: return 12
        case .indigo: return 13
        case .pink: return 14
        default: return 15
        }
    }
    
    var uiColor: UIColor { UIColor(self) }
    
}

extension Int {
    var color: Color {
        switch self {
        case 0: return .grblue
        case 1: return .grgreen
        case 2: return .red
        case 3: return .orange
        case 4: return .black
        case 5: return .white
        case 6: return .purple
        case 7: return .gray
        case 8: return .yellow
        case 9: return .green
        case 10: return .blue
        case 11: return .cyan
        case 12: return .brown
        case 13: return .indigo
        case 14: return .pink
        default: return .mint
        }
    }
}

extension UIColor {
    
    static var grgreen: UIColor { UIColor(named: "grgreen")! }
    static var grblue: UIColor { UIColor(named: "grblue")! }
    static var grgray: UIColor { UIColor(named: "grgray")! }
    static var alpha: UIColor { UIColor(named: "alpha")! }
    static var background: UIColor { UIColor(named: "background")! }
    
}
