//
//  HomeView.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 04/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct HomeView: View {
  
  @State var selectedTracking: Tracking = .disabled
  @State var selectedLayer: Layer = .IGN
  @State var selectedFilter: Filter = .all
  @State var isInfoDisplayed: Bool = false
  @State var selectedPoi: Poi?
  
  private var isInfoPoiDisplayed: Bool { selectedPoi != nil }
  
  @State private var animationAmount: CGFloat = 1
  
  var body: some View {
    
    ZStack {
      
      MapView(selectedTracking: $selectedTracking, selectedLayer: $selectedLayer, selectedFilter: $selectedFilter, selectedPoi: $selectedPoi)
        .edgesIgnoringSafeArea(.top)
      
      VStack(alignment: .trailing) {
        
        HStack(alignment: .top) {
          Spacer()
          MapControl(tracking: $selectedTracking, isInfoDisplayed: $isInfoDisplayed)
            .padding(.trailing, 8)
            .padding(.top, 16)
        }
        
        Spacer()
        
      }
      
      VStack(alignment: .leading) {
        
        Spacer()
        
        InfoView(selectedLayer: $selectedLayer, selectedFilter: $selectedFilter, isInfoDisplayed: $isInfoDisplayed)
          .offset(y: isInfoDisplayed ? 0 : 500)
          .animation(.default)
        
      }
      
      VStack(alignment: .leading) {
        
        Spacer()
        
        InfoPoiView(poi: $selectedPoi)
          .offset(y: isInfoPoiDisplayed ? 0 : 500)
          .animation(.default)
        
      }
      
      VStack {
        BlurView(effect: UIBlurEffect(style: .light))
          .frame(height: 40)
        Spacer()
      }
      .edgesIgnoringSafeArea(.top)
      
    }
    .onAppear {
      NotificationManager.shared.requestAuthorization()
      LocationManager.shared.requestAuthorization()
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
