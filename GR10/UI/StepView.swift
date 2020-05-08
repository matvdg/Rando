//
//  StepView.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

let pois = PoiRepository.shared.pois

struct StepView: View {
  var body: some View {
    NavigationView {
      List(pois) { poi in
        NavigationLink(destination: StepDetail(poi: poi)) {
          StepRow(poi: poi)
        }
      }
      .navigationBarTitle(Text("Etapes"))
    }
  }
}


struct StepView_Previews: PreviewProvider {
  static var previews: some View {
    StepView()
    .previewDevice(PreviewDevice(rawValue: "iPhone X"))
    .previewDisplayName("iPhone X")
    .environment(\.colorScheme, .dark)
  }
}
