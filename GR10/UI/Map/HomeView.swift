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
  @State var selectedDisplayMode = InfoView.DisplayMode.IGN.rawValue
  @State var isInfoDisplayed: Bool = false
  @State var selectedPoi: Poi?
  
  private var isInfoPoiDisplayed: Bool { selectedPoi != nil }
  
  @State private var animationAmount: CGFloat = 1
  
  var body: some View {
    
    
    ZStack {
      
      MapView(isCentered: $isCentered, selectedDisplayMode: $selectedDisplayMode, selectedPoi: $selectedPoi)
        .edgesIgnoringSafeArea(.top)
      
      VStack(alignment: .trailing) {
        
        HStack(alignment: .top) {
          Spacer()
          MapControl(isCentered: $isCentered, isInfoDisplayed: $isInfoDisplayed)
            .padding(.trailing, 8)
            .padding(.top, 16)
        }
        
        Spacer()
        
      }
      
      VStack(alignment: .leading) {
        
        Spacer()
        
        InfoView(selectedDisplayMode: $selectedDisplayMode, isInfoDisplayed: $isInfoDisplayed)
          .offset(y: isInfoDisplayed ? 70 : 300)
          .opacity(isInfoDisplayed ? 1 : 0)
          .animation(.default)
        
      }
      
      VStack(alignment: .leading) {
        
        Spacer()
        
        InfoPoiView(poi: $selectedPoi)
          .offset(y: isInfoPoiDisplayed ? 70 : 300)
          .opacity(isInfoPoiDisplayed ? 1 : 0)
          .animation(.default)
        
      }
      
      VStack {
        BlurView(effect: UIBlurEffect(style: .light))
          .frame(height: 40)
        Spacer()
      }
      .edgesIgnoringSafeArea(.top)
      
    }
    
  }
  
  
}

// MARK: Previews
struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
      .previewDevice(PreviewDevice(rawValue: "iPhone X"))
      .previewDisplayName("iPhone X")
      .environment(\.colorScheme, .dark)
  }
}
