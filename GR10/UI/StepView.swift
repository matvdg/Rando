//
//  StepView.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

struct StepView: View {
  
  var body: some View {
    ZStack {
      LinearGradient(gradient: Gradient(colors: [.blue, .black]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
      VStack(spacing: 30) {
        
        Text("Steps")
          .foregroundColor(.white)
          .font(.largeTitle)
          .fontWeight(.black)
        
      }
    }
    .onAppear {
      let manager = LocationManager()
      manager.request()
      //      let tiles = TileManager()
      //      tiles.saveTilesAroundPolyline()
    }
  }
  
}

struct StepView_Previews: PreviewProvider {
  static var previews: some View {
    StepView()
  }
}
