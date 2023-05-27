//
//  PoiView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

let pois = PoiManager.shared.pois

enum Filter: String, CaseIterable {
    case all, refuge, peak, waterfall
    var localized: String { rawValue.localized }
}

struct PoiView: View {
    
    @State var selectedFilter: Filter = .all
    @Binding var selectedLayer: Layer
    
    var selectedPois: [Poi] {
        var selectedPois: [Poi]
        switch selectedFilter {
        case .all: selectedPois =  pois
        case .refuge: selectedPois =  pois.filter { $0.category == .refuge }
        case .peak: selectedPois =  pois.filter { $0.category == .peak }
        default: selectedPois = pois.filter { $0.category == .waterfall }
        }
        return selectedPois.sorted { $0.alt > $1.alt }
    }
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .leading, spacing: 0) {
                
                Picker(selection: $selectedFilter, label: Text("")) {
                    ForEach(Filter.allCases, id: \.self) { filter in
                        Text(filter.localized)
                    }
                }.pickerStyle(SegmentedPickerStyle())
                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
                
                List {
                    ForEach(selectedPois) { poi in
                        NavigationLink(destination: PoiDetailView(selectedLayer: $selectedLayer, poi: poi)) {
                            PoiRow(poi: poi)
                        }
                    }
                }
                
            }
            .navigationBarTitle(Text("Steps".localized), displayMode: .inline)
            .accentColor(.tintColor)
            HStack {
                Image(systemName: "sidebar.left")
                    .imageScale(.large)
                Text("SelectInSidebar".localized)
            }
        }
        
    }
}

// MARK: Previews
struct PoiView_Previews: PreviewProvider {
    @State static var selectedLayer: Layer = .ign
    static var previews: some View {
        PoiView(selectedLayer: $selectedLayer)
            .previewDevice(PreviewDevice(rawValue: "iPhone X"))
            .previewDisplayName("iPhone X")
            .environment(\.colorScheme, .light)
    }
}
