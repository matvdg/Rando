//
//  PoiRow.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct PoiRow: View {
  
  @Binding var isHendayeToBanyuls: Bool
  
  var poi: Poi
  
  var body: some View {
    HStack(spacing: 20.0) {
      MiniImage(id: poi.id)
        .frame(width: 70.0, height: 70.0)
      VStack(alignment: .leading) {
        Text(poi.name)
          .font(.headline)
        
        HStack {
          Text(poi.altitudeInMeters)
          Text(" • ")
          Text(isHendayeToBanyuls ? poi.distanceInKilometers : poi.distanceInKilometersInverted)
        }
        .font(.subheadline)
        
      }
      
      Spacer()
    }
    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    .frame(height: 80.0)
  }
}

struct PoiRow_Previews: PreviewProvider {
  
  @State static var isHendayeToBanyuls = true
  static var previews: some View {
    
    Group {
      PoiRow(isHendayeToBanyuls: $isHendayeToBanyuls, poi: pois[0])
      PoiRow(isHendayeToBanyuls: $isHendayeToBanyuls, poi: pois[1])
    }
    .previewLayout(.fixed(width: 300, height: 80))
    .environment(\.colorScheme, .light)
  }
}
