//
//  HomeView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 04/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    @State var selectedTracking: Tracking = .bounding
    @State var selectedLayer: Layer = .ign
    @State var isInfoDisplayed: Bool = false
    @State var selectedPoi: Poi?
    @State var trails = TrailManager.shared.currentTrails
    
    private var isInfoPoiDisplayed: Bool { selectedPoi != nil }
    
    var body: some View {
        
        ZStack {
            
            MapView(selectedTracking: $selectedTracking, selectedLayer: $selectedLayer, selectedPoi: $selectedPoi, trails: $trails)
                .edgesIgnoringSafeArea(.top)
                .accentColor(.grblue)
            
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
                
                InfoView(selectedLayer: $selectedLayer, isInfoDisplayed: $isInfoDisplayed)
                    .offset(y: isInfoDisplayed ? 10 : 500)
                    .animation(.default)
                
            }
            
            VStack(alignment: .leading) {
                
                Spacer()
                
                InfoPoiView(poi: $selectedPoi)
                    .offset(y: isInfoPoiDisplayed ? 10 : 500)
                    .animation(.default)
                
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
            self.trails = TrailManager.shared.currentTrails
            self.selectedTracking = .bounding
            self.isInfoDisplayed = false
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
