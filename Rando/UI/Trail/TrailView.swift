//
//  TrailView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 06/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit
import UIKit

struct TrailView: View {
    
    enum Sorting: String, CaseIterable, Equatable {
        case importDate, name, distance, elevation
        var localized: String { self.rawValue.localized }
    }
    
    @State var showFilePicker = false
    @State var sorting: Sorting = .name
    @State var onlyDisplayed: Bool = false
    @State var onlyFavs: Bool = false
    @State var gr10filter: Gr10filter = .all
    @State var showFilter: Bool = false
    @State var department: String = "all".localized
    @State private var searchText = ""
    @Binding var selectedLayer: Layer

    private var isFiltered: Bool {
        department != "all".localized || onlyDisplayed || onlyFavs || gr10filter != .all
    }
    
    @ObservedObject var trailManager = TrailManager.shared
    
    var sortedTrails: [Trail] {
        // Sort
        var sortedTrails = trailManager.trails.array.sorted {
            switch sorting {
            case .elevation : return $0.elevationGain > $1.elevationGain
            case .distance: return $0.distance > $1.distance
            case .name: return $0.name < $1.name
            case .importDate: return $0.date > $1.date
            }
        }
        // Filter by department if necessary
        if department != "all".localized {
            sortedTrails = sortedTrails.filter { $0.department == department }
        }
        // Filter by onlyDisplayed if necessary
        if onlyDisplayed {
            sortedTrails = sortedTrails.filter { $0.isDisplayed }
        }
        // Filter by onlyFavs if necessary
        if onlyFavs {
            sortedTrails = sortedTrails.filter { $0.isFav }
        }
        // Filter by GR10 if necessary
        switch gr10filter {
        case .gr10:
            sortedTrails = sortedTrails.filter { $0.name.localizedCaseInsensitiveContains("gr10") }
        case .notgr10:
            sortedTrails = sortedTrails.filter { !$0.name.localizedCaseInsensitiveContains("gr10") }
        case .all:
            break
        }
        // Filter by search
        if !searchText.isEmpty {
            sortedTrails = sortedTrails.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return sortedTrails
    }
    
    func removeRows(at offsets: IndexSet) {
        offsets.forEach {
            let id = sortedTrails[$0].id
            trailManager.remove(id: id)
        }
    }
    
    var body: some View {
        
        NavigationView {
            ZStack {
                
                VStack {
                    HStack {
                        Picker(selection: $sorting, label: Text("")) {
                            ForEach(Sorting.allCases, id: \.self) { layer in
                                Text(layer.localized)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        Button(action: {
                            Feedback.success()
                            self.showFilter.toggle()
                        }) {
                            Image(systemName: isFiltered ? "line.horizontal.3.decrease.circle.fill" :  "line.horizontal.3.decrease.circle")
                                .tint(.tintColorTabBar)
                            Text(isFiltered ? "Filtered".localized : "Filter".localized)
                                .tint(.tintColorTabBar)
                        }
                    }
                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
                    
                    EnabledFiltersView(onlyDisplayed: $onlyDisplayed, onlyFavs: $onlyFavs, gr10filter: $gr10filter, department: $department, searchText: $searchText)
                        .isHidden(!isFiltered, remove: true)
                    
                    List {
                        ForEach(sortedTrails) { trail in
                            NavigationLink(destination: TrailDetailView(trail: trail, selectedLayer: $selectedLayer)) {
                                TrailRow(trail: trail)
                            }
                        }
                        .onDelete(perform: removeRows)
                        .accentColor(.tintColor)
                    }
                    .tint(.tintColor)
                }
                VStack(alignment: .leading) {
                    
                    Spacer()
                    
                    FilterView(onlyDisplayed: $onlyDisplayed, onlyFavs: $onlyFavs, gr10filter: $gr10filter, department: $department, isSortDisplayed: $showFilter)
                        .isHidden(!showFilter)
                        .offset(y: 10)
                }
                
            }
            .sheet(isPresented: $showFilePicker, onDismiss: { self.showFilePicker = false}) {
                DocumentView(callback: self.trailManager.createTrail, onDismiss: { self.showFilePicker = false })
            }
            .navigationBarTitle(Text("Trails".localized), displayMode: .inline)
            .navigationBarItems(leading: EditButton(), trailing:
                                    Button(action: {
                Feedback.selected()
                self.showFilePicker = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .tint(.tintColorTabBar)
            })
            HStack {
                Image(systemName: "sidebar.left")
                    .imageScale(.large)
                Text("SelectInSidebar".localized)
            }
            
        }
        .searchable(text: $searchText, placement: .toolbar, prompt: "Search".localized)
    }
    
}

// MARK: Previews
struct TrailView_Previews: PreviewProvider {
    @State static var selectedLayer: Layer = .ign
    static var previews: some View {
        TrailView(selectedLayer: $selectedLayer)
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
    }
}
