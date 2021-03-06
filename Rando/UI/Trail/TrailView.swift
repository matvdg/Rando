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
    @State var sorting: Sorting = .importDate
    @State var onlyDisplayed: Bool = false
    @State var onlyFavs: Bool = false
    @State var showFilter: Bool = false
    @State var department: String = "all".localized
    
    private var isFiltered: Bool {
        department != "all".localized || onlyDisplayed || onlyFavs
    }
    
    @ObservedObject var trailManager = TrailManager.shared
    
    var sortedTrails: [Trail] {
        // Sort
        var sortedTrails = trailManager.trails.array.sorted {
            switch sorting {
            case .elevation : return $0.positiveElevation < $1.positiveElevation
            case .distance: return $0.distance < $1.distance
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
                            Text(isFiltered ? "Filtered".localized : "Filter".localized)
                        }
                    }
                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
                    
                    List {
                        ForEach(sortedTrails) { trail in
                            NavigationLink(destination: TrailDetail(trail: trail)) {
                                TrailRow(trail: trail)
                            }
                        }
                        .onDelete(perform: removeRows)
                        .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 0))
                        .listRowBackground(Color.background)
                    }
                }
                VStack(alignment: .leading) {
                    
                    Spacer()
                    
                    FilterView(onlyDisplayed: $onlyDisplayed, onlyFavs: $onlyFavs, department: $department, isSortDisplayed: $showFilter)
                        .offset(y: showFilter ? 0 : 520)
                        .animation(.default)
                    
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
                    HStack {
                        Text("Add".localized)
                        Image(systemName: "plus")
                    }
            })
            
        }
    }
    
}

// MARK: Previews
struct TrailView_Previews: PreviewProvider {
    static var previews: some View {
        TrailView()
            .previewDevice(PreviewDevice(rawValue: "iPhone X"))
            .previewDisplayName("iPhone X")
            .environment(\.colorScheme, .dark)
    }
}
