//
//  CollectionDetailView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 04/09/2024.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct CollectionDetailView: View {
        
    @ObservedObject var collectionManager = CollectionManager.shared
    
    var collection: Collection
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            VStack {
                
                NavigationLink(destination: MapView(poi: collection.poi).navigationTitle("map")) {
                    MapView(poi: collection.poi)
                        .frame(height: 150)
                }
                
                CircleImage(poi: collection.poi)
                    .offset(x: 0, y: -130)
                    .padding(.bottom, -130)
                
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text(collection.poi.name)
                        .font(.title)
                        .fontWeight(.heavy)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("altitude")
                            .foregroundColor(Color("grgray"))
                        Text(collection.poi.altitudeInMeters).fontWeight(.bold)
                    }
                    .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
                    .isHidden(collection.poi.altitudeInMeters == "_", remove: true)
                    
                    Button(action: {
                        guard let url = self.collection.poi.phoneNumber else { return }
                        UIApplication.shared.open(url)
                        Feedback.selected()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "phone.fill")
                            Text("phone")
                                .font(.headline)
                        }
                    }
                    .isHidden(!self.collection.poi.hasPhoneNumber, remove: true)
                    
                    Button(action: {
                        guard let url = self.collection.poi.website else { return }
                        UIApplication.shared.open(url)
                        Feedback.selected()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "globe")
                            Text("website")
                                .font(.headline)
                        }
                    }
                    .isHidden(!self.collection.poi.hasWebsite, remove: true)
                    
                    Text(collection.poi.description ?? "")
                        .font(.body)
                        .foregroundColor(.text)
                        .padding(.trailing, 8)
                }
                .padding()
            }
            .navigationBarItems(trailing: Button(action: {
                collectionManager.addOrRemovePoiToCollection(poi: collection.poi)
                Feedback.selected()
            }) {
                collectionManager.isPoiAlreadyCollected(poi: collection.poi) ? Image(systemName: "trophy.fill") : Image(systemName: "trophy")
            })
        }
        .edgesIgnoringSafeArea(.horizontal)
        .navigationBarTitle(Text(collection.poi.name))
        .onAppear {
            isPlayingTour = false
        }
    }
}

// MARK: Preview
#Preview {
    CollectionDetailView(collection: Collection(id: UUID(), poi: pois[7], date: Date())).environmentObject(AppManager.shared)
}
