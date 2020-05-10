//
//  CircleButton.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct CircleButton: View {
  
  let image: String
  let action: () -> Void
  
  var body: some View {
    
    Button(action: action) {
      Image(systemName: image)
        .frame(width: 40, height: 40, alignment: .center)
        .background(Color.white)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 2))
        .shadow(radius: 1)
    }
    
  }
}

struct CircleButton_Previews: PreviewProvider {
  static var previews: some View {
    
    let action: ()->() = {}
    return Group {
      CircleButton(image: "phone.fill", action: action)
      CircleButton(image: "globe", action: action)
      CircleButton(image: "location", action: action)
    }
    .accentColor(Color.red)
    .previewLayout(.fixed(width: 100, height: 100))
    .environment(\.colorScheme, .light)
  }
}