//
//  PoiDetail.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct PoiDetail: View {
    
    var poi: Poi
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            VStack {
                
                NavigationLink(destination: OldMapView(poi: poi)) {
                    OldMapView(poi: poi)
                        .frame(height: 150)
                }
                
                CircleImage(id: poi.id)
                    .offset(x: 0, y: -130)
                    .padding(.bottom, -130)
                
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text(poi.name)
                        .font(.title)
                        .fontWeight(.heavy)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Altitude".localized)
                            .foregroundColor(Color("grgray"))
                        Text(poi.altitudeInMeters).fontWeight(.bold)
                    }
                    .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
                    
                    Button(action: {
                        guard let url = self.poi.phoneNumber else { return }
                        UIApplication.shared.open(url)
                        Feedback.selected()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "phone.fill")
                            Text("Phone".localized)
                                .font(.headline)
                        }
                    }
                    .isHidden(!self.poi.hasPhoneNumber, remove: true)
                    
                    Button(action: {
                        guard let url = self.poi.url else { return }
                        UIApplication.shared.open(url)
                        Feedback.selected()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "globe")
                            Text("Website".localized)
                                .font(.headline)
                        }
                    }
                    .isHidden(!self.poi.hasWebsite, remove: true)
                    
                    Text(poi.description ?? "")
                        .font(.body)
                        .foregroundColor(.text)
                        .padding(.trailing, 8)
                }
                
            }
            .padding()
            
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitle(Text(poi.name))
    }
}

// MARK: Previews
struct PoiDetail_Previews: PreviewProvider {
    @State static var clockwise = true
    static var previews: some View {
        PoiDetail(poi: pois[7])
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
            .previewDisplayName("iPhone SE")
            .environment(\.colorScheme, .light)
    }
}
