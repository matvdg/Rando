//
//  TrailRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct TrailRow: View {
    
  @State var trail: Trail
  
  var body: some View {
    
    HStack(spacing: 20.0) {
      
      Button(action: {
        Feedback.success()
      }) {
        Image(systemName: trail.displayed ? "eye" : "eye.slash")
          .resizable()
          .foregroundColor(trail.displayed ? .tintColor : .lightgray)
          .frame(width: 40, height: 30, alignment: .center)
      }
      
      
      VStack(alignment: .leading, spacing: 10) {
        Text(trail.name)
          .font(.headline)
        
        HStack(spacing: 8) {
          Text(trail.distance).fontWeight(.bold)
          HStack(alignment: .bottom, spacing: 4) {
            Text("PositiveElevation".localized)
              .font(.caption)
            Text(trail.positiveElevation).fontWeight(.bold)
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
  
  static var previews: some View {
    
    Group {
      TrailRow(trail: mockTrail)
      TrailRow(trail: mockTrail2)
    }
    .previewLayout(.fixed(width: 320, height: 80))
    
  }
}
