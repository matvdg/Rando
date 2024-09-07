//
//  CollectedPoiView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 04/09/2024.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct CollectedPoiView: View {
    
    @ObservedObject var collectedPoi: CollectedPoi
    @ObservedObject var collectionManager = CollectionManager.shared
    @State var showEditDateSheet: Bool = false
    @State var showEditNoteSheet: Bool = false
    
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
                
                
                VStack {
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text(collectedPoi.poi.name)
                            .font(.title)
                            .fontWeight(.heavy)
                        
                        Text(collectedPoi.date.toString)
                        
                        Button {
                            showEditDateSheet = true
                        } label: {
                            Label("editDate", systemImage: "calendar.badge.clock")
                        }
                        
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
                        
                        GroupBox {
                            Section(header: Text("personalNote").bold()) {
                                if (collectedPoi.notes ?? "").isEmpty {
                                    Text("typeHere")
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Text(collectedPoi.notes ?? "")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .onTapGesture {
                            showEditNoteSheet = true
                        }
                    }.padding()
                    CollectionPhotoGalleryView(collectedPoi: collectedPoi)
                    Spacer(minLength: 100)
                }
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
        .sheet(isPresented: $showEditDateSheet, content: {
            EditDateView(collectedPoi: collectedPoi, showEditDateSheet: $showEditDateSheet)
        })
        .sheet(isPresented: $showEditNoteSheet, content: {
            EditNoteView(collectedPoi: collectedPoi, showEditNoteSheet: $showEditNoteSheet)
        })
    }
}

// MARK: Preview
#Preview {
    CollectedPoiView(collectedPoi: CollectionManager.shared.demoCollection).environmentObject(AppManager.shared)
}
