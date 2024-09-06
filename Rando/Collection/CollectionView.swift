//
//  CollectionView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 01/09/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct CollectionView: View {
    
    enum Sorting: String, CaseIterable, Equatable {
        case date, name, altitude
        var localized: String { self.rawValue }
    }
    
    @State var sorting: Sorting = .date
    @ObservedObject var collectionManager = CollectionManager.shared
    @EnvironmentObject var appManager: AppManager
    @State var showEditDateSheet: Bool = false
    @State var selectedCollectedPoi: CollectedPoi?
    
    private var collection: [CollectedPoi] {
        var collection = collectionManager.collection
        // Filter
        switch appManager.selectedCategory {
        case .all: break
        case .refuge: collection = collection.filter { $0.poi.category == .refuge }
        case .camping: collection = collection.filter { $0.poi.category == .camping }
        case .peak: collection = collection.filter { $0.poi.category == .peak }
        case .shelter: collection = collection.filter { $0.poi.category == .shelter }
        case .waterfall: collection = collection.filter{ $0.poi.category == .waterfall }
        case .lake: collection = collection.filter{ $0.poi.category == .lake }
        default: collection = collection.filter { $0.poi.category == .pov || $0.poi.category == .bridge || $0.poi.category == .dam || $0.poi.category == .spring || $0.poi.category == .pass || $0.poi.category == .parking }
            
        }
        // Sort
        collection = collection.sorted {
            switch sorting {
            case .altitude: return $0.poi.alt ?? 0 > $1.poi.alt ?? 0
            case .name: return $0.poi.name < $1.poi.name
            case .date: return $0.date > $1.date
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
                        Image(systemName: "trophy").resizable().frame(width: 50, height: 50, alignment: .center).foregroundColor(.gray)
                        Text("emptyCollection").multilineTextAlignment(.center).foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                    .navigationBarTitle(Text("collection"), displayMode: .inline)
                    .navigationBarItems(trailing: Picker(selection: $appManager.selectedCategory, label: Text("")) {
                        ForEach(Category.allCasesForCollection, id: \.self) { filter in
                            HStack(alignment: .center, spacing: 8) {
                                Text(LocalizedStringKey(filter.rawValue))
                                filter.icon
                            }
                        }
                    })
                    .accentColor(.tintColorTabBar)
                } else {
                    ScrollView {
                        VStack {
                            Spacer().frame(height: 20)
                            
                            LazyVGrid(columns: columns, spacing: 30) {
                                ForEach(collection, id: \.self) { collectedPoi in
                                    NavigationLink {
                                        CollectedPoiView(collectedPoi: collectedPoi)
                                    } label: {
                                        VStack(alignment: .center, spacing: 4) {
                                            MiniImage(poi: collectedPoi.poi)
                                            Text(collectedPoi.poi.name).bold().foregroundColor(.primary)
                                            Text(collectedPoi.date.toString)
                                            Text(collectedPoi.poi.altitudeInMeters).isHidden(collectedPoi.poi.altitudeInMeters == "_", remove: true)
                                        }
                                        .contextMenu {
                                            Button {
                                                selectedCollectedPoi = collectedPoi
                                                
                                            } label: {
                                                Label("editDate", systemImage: "calendar.badge.clock")
                                            }
                                            Button {
                                                collectionManager.addOrRemovePoiToCollection(poi: collectedPoi.poi)
                                            } label: {
                                                collectionManager.isPoiAlreadyCollected(poi: collectedPoi.poi) ?
                                                Label("uncollect", image: "iconUncollect") : Label("collect", systemImage: "trophy")
                                            }
                                        }
                                    }
                                }
                            }.padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 8))
                        }
                    }
                    .navigationBarTitle(Text("collection (\(collection.count))"), displayMode: .inline)
                    .navigationBarItems(trailing: Picker(selection: $appManager.selectedCategory, label: Text("")) {
                        ForEach(Category.allCasesForCollection, id: \.self) { filter in
                            HStack(alignment: .center, spacing: 8) {
                                Text(LocalizedStringKey(filter.rawValue))
                                filter.icon
                            }
                        }
                    })
                    .sheet(isPresented: $showEditDateSheet, content: {
                        if let collectedPoi = selectedCollectedPoi {
                            EditDateView(collectedPoi: collectedPoi, showEditDateSheet: $showEditDateSheet)
                        }
                    })
                    .accentColor(.tintColorTabBar)
                }
                
            }
        }
        .onAppear {
            isPlayingTour = false
            collectionManager.watchiCloud()
        }
        .onDisappear {
            collectionManager.unwatchiCloud()
        }
        .onChange(of: selectedCollectedPoi, perform: { _ in
            showEditDateSheet = true
        })
    }
}

#Preview {
    CollectionView().environmentObject(AppManager.shared)
}
