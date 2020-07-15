//
//  TrailView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 06/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

struct TrailView: View {
    
    enum Sorting: String, CaseIterable, Equatable {
        case name, active, distance, elevation
        var localized: String { self.rawValue.localized }
    }
    
    @State var showFilePicker = false
    @State var sorting: Sorting = .name
    
    @ObservedObject var trailManager = TrailManager.shared
    
    var trails: [Trail] {
        if sorting == .active {
            return trailManager.trails.filter { $0.displayed }
        } else {
            return trailManager.trails.sorted {
                switch sorting {
                case .elevation : return $0.positiveElevation < $1.positiveElevation
                case .distance: return $0.distance < $1.distance
                default: return $0.name < $1.name
                }
            }
        }
    }
    
    func removeRows(at offsets: IndexSet) {
        offsets.forEach { trailManager.remove(id: self.trailManager.trails[$0].id) }
        trailManager.trails.remove(atOffsets: offsets)
    }
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                Picker(selection: $sorting, label: Text("")) {
                    ForEach(Sorting.allCases, id: \.self) { layer in
                        Text(layer.localized)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                List {
                    ForEach(trails) { trail in
                        NavigationLink(destination: TrailDetail(trail: trail)) {
                            TrailRow(trail: trail)
                        }
                    }
                    .onDelete(perform: removeRows)
                }
            }
            .sheet(isPresented: $showFilePicker, onDismiss: {self.showFilePicker = false}) {
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
