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
  @State var isInfoDisplayed: Bool = false
  @State var selectedDisplayMode = InfoView.DisplayMode.ign.rawValue
  @State private var animationAmount: CGFloat = 1
  
  var body: some View {
    
    ZStack {
      
      MapView(isCentered: $isCentered, selectedDisplayMode: $selectedDisplayMode)
      
      VStack(alignment: .trailing) {
        
        HStack(alignment: .top) {
          Spacer()
          MapControl(isCentered: $isCentered, isInfoDisplayed: $isInfoDisplayed)
            .padding()
            .padding(.top, 32)
        }
        
        Spacer()
        
        InfoView(selectedDisplayMode: $selectedDisplayMode, isInfoDisplayed: $isInfoDisplayed)
          .offset(y: isInfoDisplayed ? 140 : 300)
          .opacity(isInfoDisplayed ? 1 : 0)
          .animation(.default)
          
      }
      
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
