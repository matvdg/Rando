//
//  ContentView.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

struct ContentView: View {
  @State private var selection = 0
  @State private var userCoordinates = CLLocationCoordinate2D(latitude: 42.835191, longitude: 0.872005)
  
  var body: some View {
    TabView(selection: $selection) {
      MapView()
        .tabItem {
          VStack {
            Image(systemName: "map")
            Text("Carte")
          }
      }
      .edgesIgnoringSafeArea(.all)
      .tag(0)
      StepView()
        .tabItem {
          VStack {
            Image(systemName: "mappin.and.ellipse")
            Text("Etapes")
          }
      }
      .edgesIgnoringSafeArea(.all)
      .tag(1)
    }
    .onAppear {
      let manager = LocationManager()
      manager.request()
    }
  }
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .previewDevice(PreviewDevice(rawValue: "iPhone X"))
      .previewDisplayName("iPhone X")
      .environment(\.colorScheme, .dark)
  }
}
