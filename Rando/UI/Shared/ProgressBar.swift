//
//  ProgressBar.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 09/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct ProgressBar: View {
  @Binding var value: Float
  
  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
          .opacity(0.3)
          .foregroundColor(Color.lightgrayInverted)
        
        Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
          .foregroundColor(.tintColor)
          .animation(.linear)
      }.cornerRadius(5)
    }
    .shadow(radius: 5)
  }
}

// MARK: Previews
struct ProgressBar_Previews: PreviewProvider {
  
  @State static var value: Float = 0.2
  
  static var previews: some View {
    ProgressBar(value: $value)
    .accentColor(Color.grblue)
    .previewLayout(.fixed(width: 300, height: 20))
  }
}
