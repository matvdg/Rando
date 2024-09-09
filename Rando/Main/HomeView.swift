//
//  HomeView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 04/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

struct HomeView: View {
    
    @EnvironmentObject var appManager: AppManager
    
    @State var selectedTracking: Tracking = .bounding
    @State var isLayerViewDisplayed: Bool = false
    @State var selectedPoi: Poi?
    @State var searchTilePaths =  [MKTileOverlayPath]()
    @State var selectedSearchTilePath:  MKTileOverlayPath?
    @State var trails = TrailManager.shared.currentTrails
    
    private var isInfoPoiViewDisplayed: Bool { selectedPoi != nil }
    
    var body: some View {
        
        ZStack {
            
            MapView(selectedPoi: $selectedPoi, trails: $trails, searchTilePath: $selectedSearchTilePath)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .trailing) {
                
                SearchBar(searchTilePaths: $searchTilePaths, selectedSearchTilePath: $selectedSearchTilePath)
                    .padding()
                    .isHidden(appManager.isMapFullScreen || !appManager.hasSearchDataInCloud)
                
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
                    .offset(y: 50)
            }
            
            VStack(alignment: .leading) {
                
                Spacer()
                
                InfoPoiView(poi: $selectedPoi)
                    .isHidden(!isInfoPoiViewDisplayed)
                    .offset(y: 50)
            }
            
        }
        .onAppear {
            LocationManager.shared.requestAuthorization()
            self.trails = TrailManager.shared.currentTrails
            self.selectedTracking = .bounding
            isPlayingTour = false
        }
        
    }
    
}

// MARK: Preview
#Preview {
    HomeView().environmentObject(AppManager.shared)
}

