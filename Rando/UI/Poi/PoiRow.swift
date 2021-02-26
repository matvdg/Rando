//
//  PoiRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct PoiRow: View {
    
  var poi: Poi
  
  var body: some View {
    
    HStack(spacing: 20.0) {
      
      MiniImage(id: poi.id)
        .frame(width: 70.0, height: 70.0)
      
      VStack(alignment: .leading, spacing: 10) {
        Text(poi.name)
          .font(.headline)
        
        HStack(spacing: 8) {
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
    .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
    .frame(height: 80.0)
  }
  
}

// MARK: Previews
struct PoiRow_Previews: PreviewProvider {
  
  @State static var clockwise = true
  static var previews: some View {
    
    Group {
        PoiRow(poi: pois[0])
            .preferredColorScheme(.dark)
    }
    .previewLayout(.fixed(width: 320, height: 80))
    
  }
}
