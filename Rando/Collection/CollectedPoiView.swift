//
//  CollectedPoiView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 04/09/2024.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct CollectedPoiView: View {
        
    @ObservedObject var collectionManager = CollectionManager.shared
    
    var collectedPoi: CollectedPoi
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            VStack {
                
                NavigationLink(destination: MapView(poi: collectedPoi.poi).navigationTitle("map")) {
                    MapView(poi: collectedPoi.poi)
                        .frame(height: 150)
                }
                
                CircleImage(poi: collectedPoi.poi)
                    .offset(x: 0, y: -130)
                    .padding(.bottom, -130)
                
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text(collectedPoi.poi.name)
                        .font(.title)
                        .fontWeight(.heavy)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("altitude")
                            .foregroundColor(Color("grgray"))
                        Text(collectedPoi.poi.altitudeInMeters).fontWeight(.bold)
                    }
                    .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
                    .isHidden(collectedPoi.poi.altitudeInMeters == "_", remove: true)
                    
                    Button(action: {
                        guard let url = self.collectedPoi.poi.phoneNumber else { return }
                        UIApplication.shared.open(url)
                        Feedback.selected()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "phone.fill")
                            Text("phone")
                                .font(.headline)
                        }
                    }
                    .isHidden(!self.collectedPoi.poi.hasPhoneNumber, remove: true)
                    
                    Button(action: {
                        guard let url = self.collectedPoi.poi.website else { return }
                        UIApplication.shared.open(url)
                        Feedback.selected()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "globe")
                            Text("website")
                                .font(.headline)
                        }
                    }
                    .isHidden(!self.collectedPoi.poi.hasWebsite, remove: true)
                    
                    Text(collectedPoi.poi.description ?? "")
                        .font(.body)
                        .foregroundColor(.text)
                        .padding(.trailing, 8)
                }
                .padding()
            }
            .navigationBarItems(trailing: Button(action: {
                collectionManager.addOrRemovePoiToCollection(poi: collectedPoi.poi)
                Feedback.selected()
            }) {
                collectionManager.isPoiAlreadyCollected(poi: collectedPoi.poi) ? Image(systemName: "trophy.fill") : Image(systemName: "trophy")
            })
        }
        .edgesIgnoringSafeArea(.horizontal)
        .navigationBarTitle(Text(collectedPoi.poi.name))
        .onAppear {
            isPlayingTour = false
        }
    }
}

// MARK: Preview
#Preview {
    CollectedPoiView(collectedPoi: CollectionManager.shared.demoCollection).environmentObject(AppManager.shared)
}
