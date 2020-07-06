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
  
  var trails = [mockTrail, mockTrail2]
  
  var body: some View {
    
    NavigationView {
      
      VStack {
        List(trails) { trail in
          NavigationLink(destination: TrailDetail(trail: trail)) {
            TrailRow(trail: trail)
          }
        }
      }
        
      .navigationBarTitle(Text("Trails".localized), displayMode: .inline)
      .navigationBarItems(trailing:
        Button(action: {
          Feedback.selected()
        }) {
          Image(systemName: "plus")
      })
    }
    
  }
}

// MARK: Previews
struct PoiView_Previews: PreviewProvider {
  static var previews: some View {
    TrailView()
      .previewDevice(PreviewDevice(rawValue: "iPhone X"))
      .previewDisplayName("iPhone X")
      .environment(\.colorScheme, .dark)
  }
}
