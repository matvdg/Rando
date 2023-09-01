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
    case all, refuge, peak, waterfall, shelter
    var localized: String { rawValue }
    var icon: Image {
        switch self {
        case .all: return Image(systemName: "infinity")
        case .refuge: return Image(systemName: "house.lodge.fill")
        case .peak: return Image(systemName: "mountain.2")
        case .waterfall: return Image(systemName: "camera")
        case .shelter: return Image(systemName: "house")
        }
    }
}

struct PoiView: View {
    
    enum Sorting: String, CaseIterable, Equatable {
        case altitude, name
        var localized: String { self.rawValue }
    }
    
    @State var selectedFilter: Filter = .all
    @State private var searchText = ""
    @State var sorting: Sorting = .altitude

    @Binding var selectedLayer: Layer
    
    var selectedPois: [Poi] {
        var filteredAndSortedPois: [Poi]
        switch selectedFilter {
        case .all: filteredAndSortedPois =  pois
        case .refuge: filteredAndSortedPois =  pois.filter { $0.category == .refuge }
        case .peak: filteredAndSortedPois =  pois.filter { $0.category == .peak }
        case .shelter: filteredAndSortedPois =  pois.filter { $0.category == .shelter }
        default: filteredAndSortedPois = pois.filter { $0.category == .waterfall }
        }
        // Filter by search
        if !searchText.isEmpty {
            filteredAndSortedPois = filteredAndSortedPois.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return filteredAndSortedPois.sorted {
            switch sorting {
            case .altitude: return $0.alt ?? 0 > $1.alt ?? 0
            case .name: return $0.name < $1.name
            }
        }
            
    }
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .leading, spacing: 0) {
                Picker(selection: $sorting, label: Text("")) {
                    ForEach(Sorting.allCases, id: \.self) { sort in
                        Text(LocalizedStringKey(sort.rawValue))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
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
