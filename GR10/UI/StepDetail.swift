//
//  StepDetail.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct StepDetail: View {
  
  var poi: Poi
  
  var body: some View {
    VStack {
      MiniMapView(coordinate: poi.coordinates)
        .edgesIgnoringSafeArea(.top)
        .frame(height: 300)
      
      CircleImage(category: poi.category)
        .offset(x: 0, y: -130)
        .padding(.bottom, -130)
      
      VStack(alignment: .leading, spacing: 20.0) {
        Text(poi.name)
          .font(.title)
        
        HStack(alignment: .center, spacing: 20.0) {
          
          CircleButton(image: "phone.circle.fill") {
            guard let url = self.poi.phoneNumber else { return }
            UIApplication.shared.open(url)
          }
          .isHidden(!self.poi.hasPhoneNumber, remove: true)
          
          CircleButton(image: "link.circle.fill") {
            guard let url = self.poi.url else { return }
            UIApplication.shared.open(url)
          }
          .isHidden(!self.poi.hasWebsite, remove: true)
        
          
          Text(poi.altitudeInMeters)
            .fontWeight(.bold)
          
          Text("•")
          
          Text(poi.distanceInKilometers)
          
        }
        .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
        
        Text(poi.description ?? "")
          .font(.body)
        
      }
      .padding()
      
      Spacer()
    }
    .navigationBarTitle(Text(poi.name), displayMode: .inline)
  }
}

struct StepDetail_Previews: PreviewProvider {
  static var previews: some View {
    StepDetail(poi: pois.first!)
      .previewDevice(PreviewDevice(rawValue: "iPhone X"))
      .previewDisplayName("iPhone X")
      .environment(\.colorScheme, .dark)
  }
}
