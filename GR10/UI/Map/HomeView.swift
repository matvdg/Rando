//
//  HomeView.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 04/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct HomeView: View {
  
  @State var isHendayeToBanyuls = true
  @State private var animationRotationAmount = 0.0
  @State var selectedTracking: Tracking = .disabled
  @State var selectedLayer: Layer = .ign
  @State var selectedFilter: Filter = .all
  @State var isInfoDisplayed: Bool = false
  @State var isPlayingTour: Bool = false
  @State var selectedPoi: Poi?
  
  private var isInfoPoiDisplayed: Bool { selectedPoi != nil }
    
  var body: some View {
    
    ZStack {
      
      MapView(selectedTracking: $selectedTracking, selectedLayer: $selectedLayer, selectedFilter: $selectedFilter, selectedPoi: $selectedPoi, isPlayingTour: $isPlayingTour, isHendayeToBanyuls: $isHendayeToBanyuls)
      .edgesIgnoringSafeArea(.top)
      
      VStack(alignment: .trailing) {
        
        HStack(alignment: .top) {
          Spacer()
          MapControl(tracking: $selectedTracking, isInfoDisplayed: $isInfoDisplayed)
            .padding(.trailing, 8)
            .padding(.top, 16)
            .isHidden(isPlayingTour)
        }
        
        Spacer()
        
      }
      
      VStack(alignment: .leading) {
        
        Spacer()
        
        InfoView(selectedLayer: $selectedLayer, selectedFilter: $selectedFilter, isInfoDisplayed: $isInfoDisplayed, isPlayingTour: $isPlayingTour)
          .offset(y: isInfoDisplayed ? 0 : 500)
          .animation(.default)
        
      }
      
      VStack(alignment: .leading) {
        
        Spacer()
        
        InfoPoiView(poi: $selectedPoi)
          .offset(y: isInfoPoiDisplayed ? 0 : 500)
          .animation(.default)
        
      }
      
      VStack(alignment: .trailing) {
        
        HStack(alignment: .center) {
          
          Button(action: {
            self.isPlayingTour = false
          }) {
            Text("Stop".localized)
              .foregroundColor(.text)
          }
          .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
          .background(Color.alpha)
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .shadow(radius: 1)
          .padding(.top, 8)
          .isHidden(!isPlayingTour)
          
          
          
          Button(action: {
            self.isHendayeToBanyuls.toggle()
            self.animationRotationAmount += .pi
          }) {
            HStack {
              Text("Direction".localized)
              Image(systemName: "arrow.2.circlepath")
                .rotation3DEffect(.radians(animationRotationAmount), axis: (x: 0, y: 0, z: 1))
                .animation(.default)
            }
            .foregroundColor(.text)
          }
          .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
          .background(Color.alpha)
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .shadow(radius: 1)
          .padding(.top, 8)
          .isHidden(!isPlayingTour)
          
        }
        
        Spacer()
        
      }
      #if !targetEnvironment(macCatalyst)
      VStack {
        BlurView(effect: UIBlurEffect(style: .light))
          .frame(height: 40)
        Spacer()
      }
      .edgesIgnoringSafeArea(.top)
      #endif
      
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
