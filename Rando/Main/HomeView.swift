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
    @Binding var selectedLayer: Layer
    @Binding var isLocked: Bool
    @State var isLayerViewDisplayed: Bool = false
    @State var selectedPoi: Poi?
    @State var poiFilter: LayerView.PoiFilter = .none
    @State var trails = TrailManager.shared.currentTrails
    
    private var isInfoPoiViewDisplayed: Bool { selectedPoi != nil }
    
    var body: some View {
        
        ZStack {
            
            OldMapView(selectedTracking: $selectedTracking, selectedLayer: $selectedLayer, selectedPoi: $selectedPoi, trails: $trails, poiFilter: $poiFilter)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .trailing) {
                
                HStack(alignment: .top) {
                    Spacer()
                    MapControlView(tracking: $selectedTracking, isLayerViewDisplayed: $isLayerViewDisplayed, isLocked: $isLocked)
                        .padding(.trailing, 8)
                        .padding(.top, 70)
                }
                
                Spacer()
                
            }
            
            VStack(alignment: .leading) {
                
                Spacer()
                
                LayerView(selectedLayer: $selectedLayer, isLayerDisplayed: $isLayerViewDisplayed, filter: $poiFilter)
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
    @State static var selectedLayer: Layer = .ign
    @State static var isLocked = false
    static var previews: some View {
        HomeView(selectedLayer: $selectedLayer, isLocked: $isLocked)
            .previewDevice(PreviewDevice(rawValue: "iPhone X"))
            .previewDisplayName("iPhone X")
            .environment(\.colorScheme, .dark)
    }
}
