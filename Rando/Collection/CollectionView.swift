//
//  CollectionView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 01/09/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct CollectionView: View {
    
    enum Sorting: String, CaseIterable, Equatable {
        case importDate, name, altitude
        var localized: String { self.rawValue }
    }
    
    @State var selectedFilter: Filter = .all
    @State var sorting: Sorting = .importDate
    @Binding var selectedLayer: Layer
    @ObservedObject var collectionManager = CollectionManager.shared
    
    private var collection: [Collection] {
        var collection = collectionManager.collection
        // Filter
        switch selectedFilter {
        case .all: break
        case .refuge: collection = collection.filter { $0.poi.category == .refuge }
        case .peak: collection = collection.filter { $0.poi.category == .peak }
        case .sheld: collection = collection.filter { $0.poi.category == .sheld }
        default: collection = collection.filter{ $0.poi.category == .waterfall }
        }
        // Sort
        collection = collection.sorted {
            switch sorting {
            case .altitude: return $0.poi.alt ?? 0 > $1.poi.alt ?? 0
            case .name: return $0.poi.name < $1.poi.name
            case .importDate: return $0.date > $1.date
            }
        }
        return collection
    }
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let poi = CollectionManager.shared.$collection
    
    var body: some View {
        NavigationView {
            
            VStack {
                Picker(selection: $sorting, label: Text("")) {
                    ForEach(Sorting.allCases, id: \.self) { sort in
                        Text(LocalizedStringKey(sort.rawValue))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                if collection.isEmpty {
                    VStack(alignment: .center, spacing: 8) {
                        Spacer()
                        Text("emptyCollection").foregroundColor(.gray)
                        Spacer()
                    }
                    .navigationBarTitle(Text("Collection"), displayMode: .inline)
                    .navigationBarItems(leading: Picker(selection: $selectedFilter, label: Text("")) {
                        ForEach(Filter.allCases, id: \.self) { filter in
                            HStack(alignment: .center, spacing: 8) {
                                Text(LocalizedStringKey(filter.rawValue))
                                filter.icon
                            }
                        }
                    })
                    .accentColor(.tintColor)
                } else {
                    ScrollView {
                        VStack {
                            Spacer().frame(height: 20)
                            
                            LazyVGrid(columns: columns, spacing: 30) {
                                ForEach(collection, id: \.self) { collection in
                                    NavigationLink {
                                        PoiDetailView(selectedLayer: $selectedLayer, poi: collection.poi)
                                    } label: {
                                        VStack(alignment: .center, spacing: 4) {
                                            MiniImage(poi: collection.poi)
                                            Text(collection.poi.name).bold().foregroundColor(.black)
                                            Text(collection.date.toString)
                                            Text(collection.poi.altitudeInMeters).isHidden(collection.poi.altitudeInMeters == "_", remove: true)
                                        }
                                    }
                                }
                            }.padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 8))
                        }
                    }
                    .navigationBarTitle(Text("Collection"), displayMode: .inline)
                    .navigationBarItems(leading: Picker(selection: $selectedFilter, label: Text("")) {
                        ForEach(Filter.allCases, id: \.self) { filter in
                            HStack(alignment: .center, spacing: 8) {
                                Text(LocalizedStringKey(filter.rawValue))
                                filter.icon
                            }
                        }
                    })
                    .accentColor(.tintColor)
                }
                    
            }
        }
    }
}

struct CollectionView_Previews: PreviewProvider {
    @State static var selectedLayer: Layer = .ign
    static var previews: some View {
        CollectionView(selectedLayer: $selectedLayer)
    }
}
