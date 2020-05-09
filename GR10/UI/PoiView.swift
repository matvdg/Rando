//
//  PoiView.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

let pois = PoiRepository.shared.pois


struct PoiView: View {
  
  enum DisplayMode: String, CaseIterable {
    case all = "Tous"
    case refuge = "Refuge"
    case spring = "Source"
    case waterfall = "Cascade"
  }
  
  @State var selectedDisplayMode = 0
  @State var isHendayeToBanyuls = true
  
  var selectedPois: [Poi] {
    var selectedPoid: [Poi]
    switch selectedDisplayMode {
    case 0: selectedPoid =  pois
    case 1: selectedPoid =  pois.filter { $0.category == .refuge }
    case 2: selectedPoid =  pois.filter { $0.category == .spring }
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
            Text(DisplayMode.allCases[index].rawValue).tag(index)
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
        }) {
          HStack {
            Text("Inverser")
            Image(systemName: "arrow.2.circlepath")
          }
          
        }
      )
    }
  }
}


struct PoiView_Previews: PreviewProvider {
  static var previews: some View {
    PoiView()
      .previewDevice(PreviewDevice(rawValue: "iPhone X"))
      .previewDisplayName("iPhone X")
      .environment(\.colorScheme, .dark)
  }
}
