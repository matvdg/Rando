//
//  Color.swift
//  Cagateille
//
//  Created by Mathieu Vandeginste on 10/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import UIKit

extension Color {
  
  static var gred: Color { Color("gred") }
  static var grgreen: Color { Color("grgreen") }
  static var grblue: Color { Color("grblue") }
  static var tintColor: Color { Color("tintColor") }
  static var tintColorMap: Color { Color("tintColorMap") }
  static var text: Color { Color("text") }
  static var grgray: Color { Color("grgray") }
  static var lightgray: Color { Color("lightgray") }
  static var lightgrayInverted: Color { Color("lightgrayInverted") }
  static var alpha: Color { Color("alpha") }
  
}

extension UIColor {
  
  static var gred: UIColor { UIColor(named: "gred")! }
  static var grgreen: UIColor { UIColor(named: "grgreen")! }
  static var grblue: UIColor { UIColor(named: "grblue")! }
  static var grgray: UIColor { UIColor(named: "grgray")! }
  static var alpha: UIColor { UIColor(named: "alpha")! }
  
}
