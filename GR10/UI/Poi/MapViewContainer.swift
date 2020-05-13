//
//  MapViewContainer.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 12/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import CoreLocation


struct MapViewContainer: View {
  
  var poiCoordinate: CLLocationCoordinate2D
  
  var body: some View {
    MapView(poiCoordinate: poiCoordinate)
      .navigationBarTitle(Text("Map".localized))
  }
}

struct MapViewContainer_Previews: PreviewProvider {
  static var previews: some View {
    MapViewContainer(poiCoordinate: CLLocationCoordinate2D())
  }
}
