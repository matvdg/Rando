//
//  MapControl.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 10/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct MapControl: View {
  let buttonWidth: CGFloat = 22
  let width: CGFloat = 45
  @Binding var isCentered: Bool
  @Binding var isInfoDisplayed: Bool
  
  var body: some View {
    VStack() {
      Button(action: {
        self.isInfoDisplayed.toggle()
      }) {
        Image(systemName: "info.circle")
          .resizable()
          .frame(width: buttonWidth, height: buttonWidth, alignment: .center)
          .offset(y: -2)
      }
      Divider()
      Button(action: {
        self.isCentered.toggle()
      }) {
        Image(systemName: isCentered ? "location.fill" : "location")
          .resizable()
          .frame(width: buttonWidth, height: buttonWidth, alignment: .center)
          .offset(y: 3)
      }
    }
    .frame(width: width, height: width*2, alignment: .center)
    .background(Color.alpha)
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .shadow(radius: 1)
  }
}

struct MapControl_Previews: PreviewProvider {
  @State static var isCentered = false
  @State static var isInfoDisplayed = false
  static var previews: some View {
    Group {
      MapControl(isCentered: $isCentered, isInfoDisplayed: $isInfoDisplayed)
        .environment(\.colorScheme, .light)
      MapControl(isCentered: $isCentered, isInfoDisplayed: $isInfoDisplayed)
        .environment(\.colorScheme, .dark)
    }
      
    .previewLayout(.fixed(width: 60, height: 100))
  }
}
