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
  
  @State var showFilePicker = false
  var trails = [mockTrail, mockTrail2]
  
  private let trailManager = TrailManager.shared
  
  var body: some View {
    
    NavigationView {
      
      VStack {
        List(trails) { trail in
          NavigationLink(destination: TrailDetail(trail: trail)) {
            TrailRow(trail: trail)
          }
        }
      }
      .sheet(isPresented: $showFilePicker, onDismiss: {self.showFilePicker = false}) {
        DocumentView(callback: self.trailManager.createTrail, onDismiss: { self.showFilePicker = false })
      }
      .navigationBarTitle(Text("Trails".localized), displayMode: .inline)
      .navigationBarItems(trailing:
        Button(action: {
          Feedback.selected()
          self.showFilePicker = true
        }) {
          HStack {
            Text("Add".localized)
            Image(systemName: "plus")
          }
          
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
