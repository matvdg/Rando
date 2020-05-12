//
//  PoiView.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

let pois = PoiManager.shared.pois


struct PoiView: View {
  
  enum DisplayMode: Int, CaseIterable {
    case all = 0, refuge, spring, waterfall
    var localized: String { String(describing: self).localized }
  }
  
  @State var selectedDisplayMode = DisplayMode.all.rawValue
  @State var isHendayeToBanyuls = true
  @State private var animationAmount = 0.0
  
  var selectedPois: [Poi] {
    var selectedPoid: [Poi]
    switch selectedDisplayMode {
    case DisplayMode.all.rawValue: selectedPoid =  pois
    case DisplayMode.refuge.rawValue: selectedPoid =  pois.filter { $0.category == .refuge }
    case DisplayMode.spring.rawValue: selectedPoid =  pois.filter { $0.category == .spring }
    default: selectedPoid = pois.filter { $0.category == .waterfall }
    }
    selectedPoid.sort { isHendayeToBanyuls ? $0.dist < $1.dist : $0.dist > $1.dist }
    return selectedPoid
  }
  
  var body: some View {
    
    NavigationView {
      
      VStack {
        
        Picker(selection: $selectedDisplayMode, label: Text("Mode")) {
          ForEach(0..<DisplayMode.allCases.count, id: \.self) { index in
            Text(DisplayMode.allCases[index].localized).tag(index)
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
