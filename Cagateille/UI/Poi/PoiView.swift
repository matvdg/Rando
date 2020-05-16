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
  case all, refuge, peak, waterfall
  var localized: String { rawValue.localized }
}

struct PoiView: View {
    
  @State var selectedFilter: Filter = .all
  @State var isHendayeToBanyuls = true
  @State private var animationAmount = 0.0
  
  var selectedPois: [Poi] {
    var selectedPois: [Poi]
    switch selectedFilter {
    case .all: selectedPois =  pois
    case .refuge: selectedPois =  pois.filter { $0.category == .refuge }
    case .peak: selectedPois =  pois.filter { $0.category == .peak }
    default: selectedPois = pois.filter { $0.category == .waterfall }
    }
    selectedPois.sort { isHendayeToBanyuls ? $0.dist < $1.dist : $0.dist > $1.dist }
    return selectedPois
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
          NavigationLink(destination: PoiDetail(isHendayeToBanyuls: self.$isHendayeToBanyuls, poi: poi)) {
            PoiRow(isHendayeToBanyuls: self.$isHendayeToBanyuls, poi: poi)
          }
        }
      }
        
      .navigationBarTitle(Text(isHendayeToBanyuls ? "Hendaye-Banyuls" : "Banyuls-Hendaye"), displayMode: .inline)
      .navigationBarItems(trailing:
        Button(action: {
          Feedback.selected()
          self.isHendayeToBanyuls.toggle()
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
