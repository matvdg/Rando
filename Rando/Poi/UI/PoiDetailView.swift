//
//  PoiDetailView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct PoiDetailView: View {
        
    @ObservedObject var collectionManager = CollectionManager.shared
    
    var poi: Poi
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            VStack {
                
                NavigationLink(destination: MapView(poi: poi).navigationTitle("Map")) {
                    MapView(poi: poi)
                        .frame(height: 150)
                }
                
                CircleImage(poi: poi)
                    .offset(x: 0, y: -130)
                    .padding(.bottom, -130)
                
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text(poi.name)
                        .font(.title)
                        .fontWeight(.heavy)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("altitude")
                            .foregroundColor(Color("grgray"))
                        Text(poi.altitudeInMeters).fontWeight(.bold)
                    }
                    .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
                    .isHidden(poi.altitudeInMeters == "_", remove: true)
                    
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
            .navigationBarItems(trailing: Button(action: {
                collectionManager.addOrRemovePoiToCollection(poi: poi)
                Feedback.selected()
            }) {
                collectionManager.isPoiAlreadyCollected(poi: poi) ? Image(systemName: "star.fill") : Image(systemName: "star")
            })
        }
        .edgesIgnoringSafeArea(.horizontal)
        .navigationBarTitle(Text(poi.name))
        .onAppear {
            isPlayingTour = false
        }
    }
}

// MARK: Previews
struct PoiDetail_Previews: PreviewProvider {
    @State static var clockwise = true
    static var previews: some View {
        PoiDetailView(poi: pois[7])
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
            .previewDisplayName("iPhone SE")
            .environment(\.colorScheme, .light)
    }
}
