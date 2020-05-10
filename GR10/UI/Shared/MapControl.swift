//
//  MapControl.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 10/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct MapControl: View {
  
  let didTapCenter: () -> Void
  let didTapOnline: () -> Void
  let width: CGFloat = 40
  @Binding var isCentered: Bool
  @Binding var isOnline: Bool
  
  var body: some View {
    ZStack() {
      Divider()
      VStack() {
        Button(action: {
          self.isOnline.toggle()
          self.didTapOnline()
        }) {
          Image(systemName: isOnline ? "wifi" : "wifi.slash")
            .frame(width: width, height: width, alignment: .center)
        }
        Button(action: {
          self.isCentered.toggle()
          self.didTapCenter()
        }) {
          Image(systemName: isCentered ? "location.fill" : "location")
            .frame(width: width, height: width, alignment: .center)
        }
      }
    }
    .frame(width: width, height: width*2, alignment: .center)
    .background(Color("alpha80"))
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .shadow(radius: 1)
  }
}

struct MapControl_Previews: PreviewProvider {
  @State static var isCentered = false
  @State static var isOnline = false
  static var previews: some View {
    Group {
      MapControl(didTapCenter: {}, didTapOnline: {}, isCentered: $isCentered, isOnline: $isOnline)
        .environment(\.colorScheme, .light)
      MapControl(didTapCenter: {}, didTapOnline: {}, isCentered: $isCentered, isOnline: $isOnline)
      .environment(\.colorScheme, .dark)
    }
    
    .previewLayout(.fixed(width: 60, height: 100))
  }
}
