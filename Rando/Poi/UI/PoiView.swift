//
//  PoiView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit
import TipKit


struct PoiView: View {
    
    enum Sorting: String, CaseIterable, Equatable {
        case altitude, name
        var localized: String { self.rawValue }
    }
    
    @EnvironmentObject var appManager: AppManager
    @ObservedObject var collectionManager = CollectionManager.shared
    @State private var searchText = ""
    @State private var sorting: Sorting = .altitude
    
    let pois = PoiManager.shared.pois
    
    var selectedPois: [Poi] {
        var filteredAndSortedPois: [Poi]
        switch appManager.selectedCategory {
        case .all: filteredAndSortedPois =  pois
        case .peak: filteredAndSortedPois =  pois.filter { $0.category == .peak }
        case .refuge: filteredAndSortedPois =  pois.filter { $0.category == .refuge }
        case .camping: filteredAndSortedPois =  pois.filter { $0.category == .camping }
        case .shelter: filteredAndSortedPois =  pois.filter { $0.category == .shelter }
        case .shop: filteredAndSortedPois =  pois.filter { $0.category == .shop }
        case .waterfall: filteredAndSortedPois = pois.filter { $0.category == .waterfall }
        case .lake: filteredAndSortedPois = pois.filter { $0.category == .lake }
        default: filteredAndSortedPois =  pois.filter { $0.category == .pov || $0.category == .bridge || $0.category == .dam || $0.category == .spring || $0.category == .pass || $0.category == .parking }
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
                        NavigationLink(destination: PoiDetailView(poi: poi)) {
                            PoiRow(poi: poi)
                                .contextMenu {
                                    Button {
                                        collectionManager.addOrRemovePoiToCollection(poi: poi)
                                    } label: {
                                        collectionManager.isPoiAlreadyCollected(poi: poi) ?
                                        Label("uncollect", image: "iconUncollect") : Label("collect", systemImage: "trophy")
                                    }
                                }
                        }
                    }
                }
                
            }
            .searchable(text: $searchText, placement: .automatic, prompt: "search")
            .navigationBarTitle(Text("pois"), displayMode: .inline)
            .navigationBarItems(trailing:
                                    Picker(selection: $appManager.selectedCategory, label: Text("")) {
                ForEach(Category.allCasesForCollection, id: \.self) { filter in
                    HStack(alignment: .center, spacing: 8) {
                        Text(LocalizedStringKey(filter.rawValue))
                        filter.icon
                    }
                }
            }
                                
            )
            .accentColor(.tintColorTabBar)
            
            HStack {
                Image(systemName: "sidebar.left")
                    .imageScale(.large)
                Text("selectInSidebar")
            }
        }
        .onAppear {
            isPlayingTour = false
        }
        
    }
}


// MARK: Preview
#Preview {
    PoiView()
            .environmentObject(AppManager.shared)
}
