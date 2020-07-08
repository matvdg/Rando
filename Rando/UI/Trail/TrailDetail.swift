//
//  TrailDetail.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import SwiftUICharts

struct TrailDetail: View {
  
  var trail: Trail
  
  var body: some View {
    ScrollView {
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
          
          VStack {
            LineView(data: trail.elevations, title: "Profil", legend: "altitude (m)")
          }
          .frame(height: 340)
          
          VStack(alignment: .center, spacing: 8) {
            
            Button(action: {
              
            }, label: {
              Image(systemName: "square.and.arrow.down.on.square")
              Text("Download".localized)
            })
              .foregroundColor(Color.white)
              .padding()
              .background(Color.grgreen)
              .cornerRadius(5)
            
            Button(action: {
              
            }, label: {
              Image(systemName: "eye")
              Text("DisplayOnMap".localized)
            })
              .foregroundColor(Color.white)
              .padding()
              .background(Color.grgreen)
              .cornerRadius(5)
            
            HStack(spacing: 8) {
              Button(action: {
                
              }, label: {
                Image(systemName: "pencil")
                Text("Rename".localized)
              })
                .foregroundColor(Color.white)
                .padding()
                .background(Color.grblue)
                .cornerRadius(5)
              
              Button(action: {
                
              }, label: {
                Image(systemName: "trash")
                Text("Delete".localized)
              })
                .foregroundColor(Color.white)
                .padding()
                .background(Color.red)
                .cornerRadius(5)
            }
          }
          
          
          
        }
        .padding()
        
      }
      .navigationBarTitle(Text(trail.name))
    }
  }
}

// MARK: Previews
struct PoiDetail_Previews: PreviewProvider {
  static var previews: some View {
    TrailDetail(trail: mockTrail)
      .previewDevice(PreviewDevice(rawValue: "iPhone SE (1st generation)"))
      .previewDisplayName("iPhone SE")
      .environment(\.colorScheme, .light)
  }
}
