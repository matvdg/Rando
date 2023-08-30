//
//  PoiDetailView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct PoiDetailView: View {
    
    @Binding var selectedLayer: Layer
    
    var poi: Poi
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            VStack {
                
                NavigationLink(destination: OldMapView(poi: poi, selectedLayer: $selectedLayer).navigationTitle("Map")) {
                    OldMapView(poi: poi, selectedLayer: $selectedLayer)
                        .frame(height: 150)
                }
                
//                CircleImage(id: poi.id)
//                    .offset(x: 0, y: -130)
//                    .padding(.bottom, -130)
                
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text(poi.name)
                        .font(.title)
                        .fontWeight(.heavy)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Altitude")
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
                            Text("Phone")
                                .font(.headline)
                        }
                    }
                    .isHidden(!self.poi.hasPhoneNumber, remove: true)
                    
                    Button(action: {
                        guard let url = self.poi.website else { return }
                        UIApplication.shared.open(url)
                        Feedback.selected()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "globe")
                            Text("Website")
                                .font(.headline)
                        }
                    }
                    .isHidden(!self.poi.hasWebsite, remove: true)
                    
                    Text(poi.description ?? "")
                        .font(.body)
                        .foregroundColor(.text)
                        .padding(.trailing, 8)
                }
                .padding()
            }
            
        }
        .edgesIgnoringSafeArea(.horizontal)
        .navigationBarTitle(Text(poi.name))
    }
}

// MARK: Previews
struct PoiDetail_Previews: PreviewProvider {
    @State static var clockwise = true
    @State static var selectedLayer: Layer = .ign
    static var previews: some View {
        PoiDetailView(selectedLayer: $selectedLayer, poi: pois[7])
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
            .previewDisplayName("iPhone SE")
            .environment(\.colorScheme, .light)
    }
}
