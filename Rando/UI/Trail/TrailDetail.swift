//
//  TrailDetail.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct TrailDetail: View {
  
  var trail: Trail
  
  var body: some View {
    VStack {
      
      NavigationLink(destination: MapViewContainer(poiCoordinate: trail.coordinate)) {
        
        MapView(poiCoordinate: trail.coordinate)
          .frame(height: 300)
      }
      
      
      VStack(alignment: .leading, spacing: 20.0) {
        
        Text(trail.name)
          .font(.title)
          .fontWeight(.heavy)
          
        
        HStack(alignment: .center, spacing: 20.0) {
                    
          VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
              VStack(alignment: .leading, spacing: 4) {
                Text("Step".localized)
                  .foregroundColor(Color("grgray"))
                Text(trail.distance).fontWeight(.bold)
              }
            }
                        
            VStack(alignment: .leading, spacing: 8) {
              VStack(alignment: .leading, spacing: 4) {
                Text("DurationEstimated".localized)
                  .foregroundColor(Color("grgray"))
                Text(trail.positiveElevation).fontWeight(.bold)
              }
            }
            
          }
                    
          Divider()
                    
          VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
              VStack(alignment: .leading, spacing: 4) {
                Text("Altitude".localized)
                  .foregroundColor(Color("grgray"))
                Text(trail.positiveElevation).fontWeight(.bold)
              }
            }
                        
            VStack(alignment: .leading, spacing: 8) {
              VStack(alignment: .leading, spacing: 4) {
                Text("Distance".localized)
                  .foregroundColor(Color("grgray"))
                Text(trail.positiveElevation).fontWeight(.bold)
              }
            }
            
          }
          
          Divider()
          
          VStack(alignment: .leading, spacing: 8) {
            
            VStack(alignment: .leading, spacing: 8) {
              VStack(alignment: .leading, spacing: 4) {
                Text("PositiveElevation".localized)
                  .foregroundColor(Color("grgray"))
                Text(trail.positiveElevation).fontWeight(.bold)
              }
            }
                        
            VStack(alignment: .leading, spacing: 8) {
              VStack(alignment: .leading, spacing: 4) {
                Text("NegativeElevation".localized)
                  .foregroundColor(Color("grgray"))
                Text(trail.positiveElevation).fontWeight(.bold)
              }
            }

          }
          
        }
        .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
        .frame(maxHeight: 100)
        
        ScrollView {
          Text("blablabla")
            .font(.body)
            .foregroundColor(.text)
            .padding(.trailing, 8)
        }
        
      }
      .padding()
      
      Spacer()
    }
    .navigationBarTitle(Text(trail.name))
    .navigationBarItems(trailing:
      HStack(spacing: 16) {
        Button(action: {
          Feedback.selected()
        }) {
          Image(systemName: "pencil")
        }
        Button(action: {
          Feedback.selected()
        }) {
          Image(systemName: "trash")
        }
    })
  }
}

// MARK: Previews
struct PoiDetail_Previews: PreviewProvider {
  static var previews: some View {
    TrailDetail(trail: mockTrail)
      .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
      .previewDisplayName("iPhone SE")
      .environment(\.colorScheme, .light)
  }
}
