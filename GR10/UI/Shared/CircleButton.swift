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
      .resizable()
      .frame(width: 50, height: 50, alignment: .center)
    }
    
  }
}

struct CircleButton_Previews: PreviewProvider {
  static var previews: some View {
    
    let action: ()->() = {}
    return Group {
      CircleButton(image: "phone.circle.fill", action: action)
      CircleButton(image: "link.circle.fill", action: action)
    }
    .previewLayout(.fixed(width: 100, height: 100))
    .environment(\.colorScheme, .light)
  }
}
