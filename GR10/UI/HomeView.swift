//
//  HomeView.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 04/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct HomeView: View {
  
  @State var isCentered: Bool = false
  
  var body: some View {
    ZStack {
      MapView()
      HStack(alignment: .bottom, spacing: 0.0) {
        VStack(alignment: .leading) {
          Spacer()
          CircleButton(image: isCentered ? "location.fill" : "location") {
            self.isCentered.toggle()
          }
        }
        Spacer()
      }
      .padding()
    }
    .edgesIgnoringSafeArea(.top)
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
      .previewDevice(PreviewDevice(rawValue: "iPhone X"))
      .previewDisplayName("iPhone X")
      .environment(\.colorScheme, .dark)
  }
}
