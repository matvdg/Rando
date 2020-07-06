//
//  ContentView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

struct ContentView: View {
  
  @State private var selection = 0
  
  var body: some View {
    ZStack {
      TabView(selection: $selection) {
        HomeView()
          .tabItem {
            Image(systemName: "map")
        }
        .tag(0)
        TrailView()
          .tabItem {
            Image(systemName: "mappin.and.ellipse")
        }
        .tag(1)
      }
    }
    .accentColor(Color.tintColor)
  }
  
}

// MARK: Previews
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ContentView()
      .previewDevice(PreviewDevice(rawValue: "iPhone X"))
      .previewDisplayName("iPhone X")
      .environment(\.colorScheme, .dark)
    }
  }
}
