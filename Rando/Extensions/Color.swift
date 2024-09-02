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
    
    static var tintColor: Color { Color("tintColor") }
    
    var uiColor: UIColor { UIColor(self) }
    var cgColor: CGColor { uiColor.cgColor }
    
}

extension String {
    
    var hexToColor: CGColor {
        var cleanedString = self.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanedString = cleanedString.replacingOccurrences(of: "#", with: "")
        let randomColor = CGColor.randomColor
        guard cleanedString.count == 6, let rgbValue = UInt32(cleanedString, radix: 16) else {
            return randomColor
        }
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        return color.cgColor
    }
    
}

extension Color {
    static var random: Color {
        Color(cgColor: CGColor.randomColor)
    }
}

extension CGColor {
    
    static var randomColor: CGColor {
        let colors: [Color] = [.grblue, .grgreen, .red, .orange, .indigo, .pink, .purple, .gray, .yellow, .green, .blue, .cyan, .brown, .mint]
        return colors.randomElement()?.cgColor ?? CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
        
    var hexaCode: String? {
        guard let components = self.components, components.count >= 3 else {
            return nil
        }
        
        let red = Int(components[0] * 255)
        let green = Int(components[1] * 255)
        let blue = Int(components[2] * 255)
        
        let hexString = String(format: "#%02X%02X%02X", red, green, blue)
        return hexString
    }
}
