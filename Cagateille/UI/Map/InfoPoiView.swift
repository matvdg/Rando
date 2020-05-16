//
//  InfoPoiView.swift
//  Cagateille
//
//  Created by Mathieu Vandeginste on 11/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct InfoPoiView: View {
  
  @Binding var poi: Poi?
  
  var body: some View {
    
    NavigationView {
      
      HStack(alignment: .top, spacing: 16) {
        
        MiniImage(id: poi?.id ?? -1)
          .frame(width: 70.0, height: 70.0)
        VStack(alignment: .leading) {
          HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
              VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                  Text("Altitude".localized)
                    .foregroundColor(Color("grgray"))
                  Text(poi?.altitudeInMeters ?? "").fontWeight(.bold)
                }
              }
              VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                  Text("DurationEstimated".localized)
                    .foregroundColor(Color("grgray"))
                  Text(poi?.estimations.duration ?? "").fontWeight(.bold)
                }
              }
            }
            Divider()
            VStack(alignment: .leading, spacing: 8) {
              VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                  Text("Distance".localized)
                    .foregroundColor(Color("grgray"))
                  Text(poi?.estimations.distance ?? "").fontWeight(.bold)
                }
              }
              VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                  Text("PositiveElevation".localized)
                    .foregroundColor(Color("grgray"))
                  Text(poi?.estimations.positiveElevation ?? "").fontWeight(.bold)
                }
              }
            }
          }
          .font(.subheadline)
          .frame(maxHeight: 100)
          
          ScrollView {
            Text(poi?.description ?? "")
              .font(.body)
              .padding(.trailing, 8)
          }
          .frame(height: 110, alignment: .top)
          
          Spacer()
        }
        .padding(.bottom, 16)
      }
      .padding()
      .navigationBarTitle(Text(poi?.name ?? ""), displayMode: .inline)
      .navigationBarItems(leading:
        Button(action: {
          self.poi = nil
        }) {
          Image(systemName: "chevron.down")
        })
      
    }
    .navigationViewStyle(StackNavigationViewStyle())
    .frame(maxWidth: 500)
    .frame(height: 300.0, alignment: .top)
    .shadow(radius: 10)
    .gesture(DragGesture().onEnded { value in
      guard value.translation.height > 100 else { return }
      Feedback.selected()
      self.poi = nil
    })
    
  }
}

// MARK: Previews
struct InfoPoiView_Previews: PreviewProvider {
  
  @State static var poi = PoiManager.shared.pois.first
  
  static var previews: some View {
    
    Group {
      InfoPoiView(poi: $poi)
        .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
        .previewDisplayName("iPhone 11 Pro Max")
        .environment(\.colorScheme, .dark)
      InfoPoiView(poi: $poi)
        .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (3rd generation)"))
        .previewDisplayName("iPad Pro")
        .environment(\.colorScheme, .light)
      InfoPoiView(poi: $poi)
        .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
        .previewDisplayName("iPhone SE")
        .environment(\.colorScheme, .light)
    }
    
  }
}
