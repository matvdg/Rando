//
//  PoiRow.swift
//  Cagateille
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
      
      VStack(alignment: .leading, spacing: 10) {
        Text(poi.name)
          .font(.headline)
        
        HStack(spacing: 8) {
          Text(isHendayeToBanyuls ? poi.distanceInKilometers : poi.distanceInKilometersInverted).fontWeight(.bold)
          HStack(alignment: .bottom, spacing: 4) {
            Text("Altitude".localized)
              .font(.caption)
            Text(poi.altitudeInMeters).fontWeight(.bold)
          }
        }
        .font(.subheadline)
        .minimumScaleFactor(0.5)
        .lineLimit(1)
        
      }
      
      Spacer()
      
    }
    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    .frame(height: 80.0)
  }
  
}

// MARK: Previews
struct PoiRow_Previews: PreviewProvider {
  
  @State static var isHendayeToBanyuls = true
  static var previews: some View {
    
    Group {
      PoiRow(isHendayeToBanyuls: $isHendayeToBanyuls, poi: pois[0])
      PoiRow(isHendayeToBanyuls: $isHendayeToBanyuls, poi: pois[1])
    }
    .previewLayout(.fixed(width: 320, height: 80))
    
  }
}
