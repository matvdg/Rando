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
    case all, refuge, peak, waterfall, sheld
    var localized: String { rawValue }
    var icon: Image {
        switch self {
        case .all: return Image(systemName: "infinity")
        case .refuge: return Image(systemName: "house.lodge.fill")
        case .peak: return Image(systemName: "mountain.2")
        case .waterfall: return Image(systemName: "eye")
        case .sheld: return Image(systemName: "house")
        }
    }
}

struct PoiView: View {
    
    @State var selectedFilter: Filter = .all
    @State private var searchText = ""

    @Binding var selectedLayer: Layer
    
    var selectedPois: [Poi] {
        var selectedPois: [Poi]
        switch selectedFilter {
        case .all: selectedPois =  pois
        case .refuge: selectedPois =  pois.filter { $0.category == .refuge }
        case .peak: selectedPois =  pois.filter { $0.category == .peak }
        case .sheld: selectedPois =  pois.filter { $0.category == .sheld }
        default: selectedPois = pois.filter { $0.category == .waterfall }
        }
        // Filter by search
        if !searchText.isEmpty {
            selectedPois = selectedPois.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return selectedPois.sorted { $0.alt ?? 0 > $1.alt ?? 0 }
    }
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .leading, spacing: 0) {
                
                List {
                    ForEach(selectedPois) { poi in
                        NavigationLink(destination: PoiDetailView(selectedLayer: $selectedLayer, poi: poi)) {
                            PoiRow(poi: poi)
                        }
                    }
                }
                
            }
            .searchable(text: $searchText, placement: .toolbar, prompt: "Search")
            .navigationBarTitle(Text("Steps"), displayMode: .inline)
            .navigationBarItems(leading: Picker(selection: $selectedFilter, label: Text("")) {
                ForEach(Filter.allCases, id: \.self) { filter in
                    HStack(alignment: .center, spacing: 8) {
                        Text(LocalizedStringKey(filter.rawValue))
                        filter.icon
                    }
                }
            })
            .accentColor(.tintColor)
            HStack {
                Image(systemName: "sidebar.left")
                    .imageScale(.large)
                Text("SelectInSidebar")
            }
        }
        
    }
}

// MARK: Previews
struct PoiView_Previews: PreviewProvider {
    @State static var selectedLayer: Layer = .ign
    static var previews: some View {
        PoiView(selectedLayer: $selectedLayer)
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
            .environment(\.colorScheme, .light)
    }
}
