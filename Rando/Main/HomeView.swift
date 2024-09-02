//
//  HomeView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 04/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var appManager: AppManager
    
    @State var selectedTracking: Tracking = .bounding
    @State var isLayerViewDisplayed: Bool = false
    @State var selectedPoi: Poi?
    @State var trails = TrailManager.shared.currentTrails
    
    private var isInfoPoiViewDisplayed: Bool { selectedPoi != nil }
    
    var body: some View {
        
        ZStack {
            
            MapView(selectedPoi: $selectedPoi, trails: $trails)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .trailing) {
                
                HStack(alignment: .top) {
                    Spacer()
                    MapControlView(isLayerViewDisplayed: $isLayerViewDisplayed)
                        .padding(.trailing, 8)
                        .padding(.top, 70)
                }
                
                Spacer()
                
            }
            
            VStack(alignment: .leading) {
                
                Spacer()
                
                LayerView(isLayerDisplayed: $isLayerViewDisplayed)
                    .isHidden(!isLayerViewDisplayed)
                    .offset(y: 10)
            }
            
            VStack(alignment: .leading) {
                
                Spacer()
                
                InfoPoiView(poi: $selectedPoi)
                    .isHidden(!isInfoPoiViewDisplayed)
                    .offset(y: 10)
            }
            
        }
        .onAppear {
            LocationManager.shared.requestAuthorization()
            self.trails = TrailManager.shared.currentTrails
            self.selectedTracking = .bounding
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
