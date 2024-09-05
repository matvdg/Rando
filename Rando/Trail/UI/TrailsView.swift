//
//  TrailView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 06/07/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
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
    @State var onlyLoops: Bool = false
    @State var grFilter: GRFilter = .all
    @State var difficultyFilter: DifficultyFilter = .all
    @State var showFilter: Bool = false
    @State var department: String = "all"
    @State private var searchText = ""
    
    @EnvironmentObject var appManager: AppManager
    
    private var isFiltered: Bool {
        department != "all" || onlyDisplayed || onlyFavs || onlyLoops || grFilter != .all || difficultyFilter != .all
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
        // Filter by difficulty if necessary
        if difficultyFilter != .all {
            sortedTrails = sortedTrails.filter { $0.difficulty.rawValue == difficultyFilter.rawValue }
        }
        // Filter by onlyDisplayed if necessary
        if onlyDisplayed {
            sortedTrails = sortedTrails.filter { $0.isDisplayed }
        }
        // Filter by onlyFavs if necessary
        if onlyFavs {
            sortedTrails = sortedTrails.filter { $0.isFav }
        }
        // Filter by onlyLoops if necessary
        if onlyLoops {
            sortedTrails = sortedTrails.filter { $0.isLoop }
        }
        // Filter by GR/HR if necessary
        switch grFilter {
        case .gr:
            sortedTrails = sortedTrails.filter { $0.name.localizedCaseInsensitiveContains("gr") }
        case .hr:
            sortedTrails = sortedTrails.filter { $0.name.localizedCaseInsensitiveContains("hr") }
        case .notghr:
            sortedTrails = sortedTrails.filter { !$0.name.localizedCaseInsensitiveContains("gr") && !$0.name.localizedCaseInsensitiveContains("hr") }
        case .ghr:
            sortedTrails = sortedTrails.filter { $0.name.localizedCaseInsensitiveContains("gr") || $0.name.localizedCaseInsensitiveContains("hr") }
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
                            Text(isFiltered ? "filtered" : "filter")
                                .tint(.tintColorTabBar)
                        }
                    }
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
                    
                    EnabledFiltersView(onlyDisplayed: $onlyDisplayed, onlyFavs: $onlyFavs, onlyLoops: $onlyLoops, grFilter: $grFilter, difficultyFilter: $difficultyFilter, department: $department, searchText: $searchText)
                        .isHidden(!isFiltered && searchText == "", remove: true)
                    
                    List {
                        ForEach(sortedTrails) { trail in
                            NavigationLink(destination: TrailDetailView(trail: trail)) {
                                TrailRow(trail: trail)
                                    .contextMenu {
                                        Button {
                                            trail.isFav.toggle()
                                            Feedback.success()
                                            trailManager.save(trail: trail)
                                        } label: {
                                            Label(trail.isFav ? "unfav" : "fav", systemImage: trail.isFav ? "heart.slash" : "heart.fill")
                                        }
                                        Button {
                                            trail.isDisplayed.toggle()
                                            Feedback.success()
                                            trailManager.save(trail: trail)
                                        } label: {
                                            Label(trail.isDisplayed ? "hideOnMap" : "displayOnMap", systemImage: trail.isDisplayed ? "eye.slash" : "eye")

                                        }
                                        Button {
                                            trailManager.remove(id: trail.id)
                                        } label: {
                                            Label("delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .onDelete(perform: removeRows)
                        .accentColor(.tintColor)
                    }
                    .tint(.tintColor)
                }
                VStack(alignment: .leading) {
                    
                    Spacer()
                    
                    FilterView(onlyDisplayed: $onlyDisplayed, onlyFavs: $onlyFavs, onlyLoops: $onlyLoops, grFilter: $grFilter, difficultyFilter: $difficultyFilter, department: $department, isSortDisplayed: $showFilter)
                        .isHidden(!showFilter)
                        .offset(y: 10)
                }
                
            }
            .sheet(isPresented: $showImportView) {
                ImportView(showImportView: $showImportView)
            }
            .navigationBarTitle(Text("trails"), displayMode: .inline)
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
                Text("selectInSidebar")
            }
            
        }
        .searchable(text: $searchText, placement: .automatic, prompt: "search")
        .onAppear {
            NotificationManager.shared.requestAuthorization()
            isPlayingTour = false
            trailManager.watchiCloud()
        }
        .onDisappear {
            trailManager.unwatchiCloud()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    
}

// MARK: Preview
#Preview {
    TrailsView()
}
