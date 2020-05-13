//
//  PoiDetail.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct PoiDetail: View {
  
  @Binding var isHendayeToBanyuls: Bool
  
  var poi: Poi
  
  var body: some View {
    VStack {
      
      NavigationLink(destination: MapViewContainer(poiCoordinate: poi.coordinate)) {
        
        MapView(poiCoordinate: poi.coordinate)
          .frame(height: 300)
      }
      
      CircleImage(id: poi.id)
        .offset(x: 0, y: -130)
        .padding(.bottom, -130)
      
      VStack(alignment: .leading, spacing: 20.0) {
        Text(poi.name)
          .font(.title)
        
        HStack(alignment: .center, spacing: 20.0) {
          
          NavigationLink(destination: MapViewContainer(poiCoordinate: poi.coordinate)) {
            Image(systemName: "map.fill")
              .frame(width: 40, height: 40, alignment: .center)
              .background(Color.alpha)
              .clipShape(Circle())
              .overlay(Circle().stroke(Color.white, lineWidth: 2))
              .shadow(radius: 1)
          }
          
          CircleButton(image: "phone.fill") {
            guard let url = self.poi.phoneNumber else { return }
            UIApplication.shared.open(url)
            Feedback.selected()
          }
          .isHidden(!self.poi.hasPhoneNumber, remove: true)
          
          CircleButton(image: "globe") {
            guard let url = self.poi.url else { return }
            UIApplication.shared.open(url)
            Feedback.selected()
          }
          .isHidden(!self.poi.hasWebsite, remove: true)
          
          VStack(alignment: .leading) {
            HStack(spacing: 8) {
              HStack(alignment: .bottom, spacing: 4) {
                Text("Km")
                  .font(.caption)
                Text(isHendayeToBanyuls ? poi.distanceInKilometers : poi.distanceInKilometersInverted).fontWeight(.bold)
              }
              HStack(alignment: .bottom, spacing: 4) {
                Text("Altitude".localized)
                  .font(.caption)
                Text(poi.altitudeInMeters).fontWeight(.bold)
              }
            }
            HStack(spacing: 8) {
              HStack(alignment: .bottom, spacing: 4) {
                Text("Distance".localized)
                  .font(.caption)
                Text(poi.distanceFromUser).fontWeight(.bold)
              }
              Spacer()
            }
            
          }
          
          
        }
        .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
        
        ScrollView {
          Text(poi.description ?? "")
            .font(.body)
            .padding(.trailing, 8)
        }
        
      }
      .padding()
      
      Spacer()
    }
    .navigationBarTitle(Text(poi.name))
  }
}

// MARK: Previews
struct PoiDetail_Previews: PreviewProvider {
  @State static var isHendayeToBanyuls = true
  static var previews: some View {
    PoiDetail(isHendayeToBanyuls: $isHendayeToBanyuls, poi: pois.first!)
      .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
      .previewDisplayName("iPhone SE")
      .environment(\.colorScheme, .dark)
  }
}
