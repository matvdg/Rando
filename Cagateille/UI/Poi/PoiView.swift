//
//  PoiView.swift
//  Cagateille
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

let pois = PoiManager.shared.pois

enum Filter: String, CaseIterable {
  case all, refuge, lake
  var localized: String { rawValue.localized }
}

struct PoiView: View {
    
  @State var selectedFilter: Filter = .all
  @State var clockwise = true
  @State private var animationAmount = 0.0
  
  var selectedPois: [Poi] {
    var selectedPois: [Poi]
    switch selectedFilter {
    case .all: selectedPois =  pois
    case .refuge: selectedPois =  pois.filter { $0.category == .refuge }
    case .lake: selectedPois =  pois.filter { $0.category == .lake }
    default: selectedPois = pois.filter { $0.category == .waterfall }
    }
    return selectedPois.sorted { clockwise ? $0.id < $1.id : $0.id > $1.id }
  }
  
  var body: some View {
    
    NavigationView {
      
      VStack {
        
        Picker(selection: $selectedFilter, label: Text("")) {
          ForEach(Filter.allCases, id: \.self) { filter in
            Text(filter.localized)
          }
        }.pickerStyle(SegmentedPickerStyle())
          .padding()
        
        List(selectedPois) { poi in
          NavigationLink(destination: PoiDetail(clockwise: self.$clockwise, poi: poi)) {
            PoiRow(clockwise: self.$clockwise, poi: poi)
          }
        }
      }
        
      .navigationBarTitle(Text("Steps".localized), displayMode: .inline)
      .navigationBarItems(trailing:
        Button(action: {
          Feedback.selected()
          self.clockwise.toggle()
          self.animationAmount += .pi
        }) {
          HStack {
            Text("Direction".localized)
            Image(systemName: "arrow.2.circlepath")
              .rotation3DEffect(.radians(animationAmount), axis: (x: 0, y: 0, z: 1))
              .animation(.default)
          }
          
        }
      )
    }
    
  }
}

// MARK: Previews
struct PoiView_Previews: PreviewProvider {
  static var previews: some View {
    PoiView()
      .previewDevice(PreviewDevice(rawValue: "iPhone X"))
      .previewDisplayName("iPhone X")
      .environment(\.colorScheme, .dark)
  }
}
