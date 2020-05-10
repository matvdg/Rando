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
  @State var hideDownloadView: Bool = false
  private let tileManager = TileManager.shared
  
  var body: some View {
    ZStack {
      TabView(selection: $selection) {
        HomeView()
          .tabItem {
            VStack {
              Image(systemName: "map")
              Text("Map".localized)
            }
        }
        .tag(0)
        PoiView()
          .tabItem {
            VStack {
              Image(systemName: "mappin.and.ellipse")
              Text("Pois".localized)
            }
        }
        .tag(1)
      }
      if !tileManager.hasRecordedTiles {
        DownloadView(hideDownloadView: $hideDownloadView)
        .isHidden(hideDownloadView, remove: true)
      } else {
        /*@START_MENU_TOKEN@*/EmptyView()/*@END_MENU_TOKEN@*/
      }
    }
    .accentColor(Color.gred)
  }
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ContentView()
      .previewDevice(PreviewDevice(rawValue: "iPhone X"))
      .previewDisplayName("iPhone X")
      .environment(\.colorScheme, .dark)
//      ContentView()
//      .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
//      .previewDisplayName("iPhone SE")
//      .environment(\.colorScheme, .light)
//      ContentView()
//      .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (3rd generation)"))
//      .previewDisplayName("iPad Pro")
//      .environment(\.colorScheme, .light)
    }
  }
}
