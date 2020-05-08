//
//  StepRow.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct StepRow: View {
  
  var poi: Poi
  
  var body: some View {
    HStack(spacing: 20.0) {
      MiniImage(category: poi.category)
      VStack(alignment: .leading) {
        Text(poi.name)
          .font(.headline)
        
        HStack {
          Text(poi.altitudeInMeters)
          Text(" • ")
          Text(poi.distanceInKilometers)
        }
        .font(.subheadline)
        
      }
      
      Spacer()
    }
    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
  }
}

struct StepRow_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      StepRow(poi: pois[0])
      StepRow(poi: pois[1])
    }
    .previewLayout(.fixed(width: 300, height: 70))
    .environment(\.colorScheme, .light)
  }
}
