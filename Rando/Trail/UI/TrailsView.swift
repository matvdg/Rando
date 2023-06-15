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

struct TrailsView: View {
    
    enum Sorting: String, CaseIterable, Equatable {
        case importDate, name, distance, elevation
        var localized: String { self.rawValue }
    }
    
    @State var showImportView = false
    @State var sorting: Sorting = .importDate
    @State var onlyDisplayed: Bool = false
    @State var onlyFavs: Bool = false
    @State var gr10filter: Gr10filter = .all
    @State var showFilter: Bool = false
    @State var department: String = "all"
    @State private var searchText = ""
    @Binding var selectedLayer: Layer
    
    private var isFiltered: Bool {
        department != "all" || onlyDisplayed || onlyFavs || gr10filter != .all
    }
    
    @ObservedObject var trailManager = TrailManager.shared
    
    private var sortedTrails: [Trail] {
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
        if department != "all" {
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
                            ForEach(Sorting.allCases, id: \.self) { sort in
                                Text(LocalizedStringKey(sort.rawValue))
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        Button(action: {
                            Feedback.selected()
                            hideKeyboard()
                            showFilter.toggle()
                        }) {
                            Image(systemName: isFiltered ? "line.horizontal.3.decrease.circle.fill" :  "line.horizontal.3.decrease.circle")
                                .tint(.tintColorTabBar)
                            Text(isFiltered ? "Filtered" : "Filter")
                                .tint(.tintColorTabBar)
                        }
                    }
                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
                    
                    EnabledFiltersView(onlyDisplayed: $onlyDisplayed, onlyFavs: $onlyFavs, gr10filter: $gr10filter, department: $department, searchText: $searchText)
                        .isHidden(!isFiltered && searchText == "", remove: true)
                    
                    List {
                        ForEach(sortedTrails) { trail in
                            NavigationLink(destination: TrailView(trail: trail, selectedLayer: $selectedLayer)) {
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
            .sheet(isPresented: $showImportView) {
                ImportView(showImportView: $showImportView)
            }
            .navigationBarTitle(Text("Trails"), displayMode: .inline)
            .navigationBarItems(leading: EditButton(), trailing:
                                    Button(action: {
                Feedback.selected()
                self.showImportView = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .tint(.tintColorTabBar)
            })
            HStack {
                Image(systemName: "sidebar.left")
                    .imageScale(.large)
                Text("SelectInSidebar")
            }
            
        }
        .searchable(text: $searchText, placement: .toolbar, prompt: "Search")
        .onAppear {
            NotificationManager.shared.requestAuthorization()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    
}

// MARK: Previews
struct TrailsView_Previews: PreviewProvider {
    @State static var selectedLayer: Layer = .ign
    static var previews: some View {
        TrailsView(selectedLayer: $selectedLayer)
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
    }
}
