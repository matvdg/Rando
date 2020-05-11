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
      MapView(isCentered: Binding<Bool>.constant(false), selectedDisplayMode: Binding<Int>.constant(0), poiCoordinate: poi.coordinates)
        .edgesIgnoringSafeArea(.top)
        .frame(height: 300)
      
      CircleImage(id: poi.id)
        .offset(x: 0, y: -130)
        .padding(.bottom, -130)
      
      VStack(alignment: .leading, spacing: 20.0) {
        Text(poi.name)
          .font(.title)
        
        HStack(alignment: .center, spacing: 20.0) {
          
          CircleButton(image: "phone.fill") {
            guard let url = self.poi.phoneNumber else { return }
            UIApplication.shared.open(url)
          }
          .isHidden(!self.poi.hasPhoneNumber, remove: true)
          
          CircleButton(image: "globe") {
            guard let url = self.poi.url else { return }
            UIApplication.shared.open(url)
          }
          .isHidden(!self.poi.hasWebsite, remove: true)
        
          
          Text(poi.altitudeInMeters)
            .fontWeight(.bold)
          
          Text("•")
          
          Text(isHendayeToBanyuls ? poi.distanceInKilometers : poi.distanceInKilometersInverted)
          
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
    .navigationBarTitle(Text(poi.name), displayMode: .inline)
  }
}

struct PoiDetail_Previews: PreviewProvider {
  @State static var isHendayeToBanyuls = true
  static var previews: some View {
    PoiDetail(isHendayeToBanyuls: $isHendayeToBanyuls, poi: pois.first!)
      .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
      .previewDisplayName("iPhone SE")
      .environment(\.colorScheme, .dark)
  }
}
