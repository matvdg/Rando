//
//  InfoPoiView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 11/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct InfoPoiView: View {
    
    @Binding var poi: Poi?
    
    @ObservedObject var collectionManager = CollectionManager.shared
    
    var body: some View {
        
        NavigationView {
            
            HStack(alignment: .top, spacing: 16) {
                
                MiniImage(poi: poi ?? Poi())
                    .frame(width: 70.0, height: 70.0)
                
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("altitude")
                                .foregroundColor(Color("grgray"))
                            Text(poi?.altitudeInMeters ?? "_").fontWeight(.bold)
                        }.isHidden(poi?.altitudeInMeters ?? "_" == "_", remove: true)
                        VStack(alignment: .leading, spacing: 4) {
                            Button(action: {
                                guard let url = poi?.phoneNumber else { return }
                                UIApplication.shared.open(url)
                                Feedback.selected()
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "phone.fill")
                                    Text("phone")
                                        .font(.headline)
                                }
                            }
                            .isHidden(!(poi?.hasPhoneNumber ?? false), remove: true)
                            
                            Button(action: {
                                guard let url = poi?.website else { return }
                                UIApplication.shared.open(url)
                                Feedback.selected()
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "globe")
                                    Text("website")
                                        .font(.headline)
                                }
                            }
                            .isHidden(!(poi?.hasWebsite ?? false), remove: true)
                        }
                    }
                    .font(.subheadline)
                    .frame(maxHeight: 100)
                    .isHidden(poi?.altitudeInMeters ?? "_" == "_" && !(poi?.hasPhoneNumber ?? false) && !(poi?.hasWebsite ?? false), remove: true)
                    
                    ScrollView(showsIndicators: false) {
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
            .navigationBarTitle(poi?.name ?? "", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                poi = nil
                Feedback.selected()
            }) {
                DismissButton()
            })
            .navigationBarItems(leading: Button(action: {
                if let poi {
                    collectionManager.addOrRemovePoiToCollection(poi: poi)
                    Feedback.selected()
                    self.poi = nil
                }
            }) {
                if let poi {
                    collectionManager.isPoiAlreadyCollected(poi: poi) ? Image(systemName: "trophy.fill") : Image(systemName: "trophy")
                }
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .frame(maxWidth: 500)
        .frame(height: 350, alignment: .top)
        .cornerRadius(8)
        .shadow(radius: 10)
        
    }
}

// MARK: Preview
#Preview {
    InfoPoiView(poi: .constant(PoiManager.shared.pois.first))
}
