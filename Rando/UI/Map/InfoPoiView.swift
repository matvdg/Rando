//
//  InfoPoiView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 11/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct InfoPoiView: View {
    
    @Binding var poi: Poi?
    
    var body: some View {
        
        NavigationView {
            
            HStack(alignment: .top, spacing: 16) {
                
                MiniImage(id: poi?.id ?? 0)
                    .frame(width: 70.0, height: 70.0)
                
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Altitude".localized)
                            .foregroundColor(Color("grgray"))
                        Text(poi?.altitudeInMeters ?? "").fontWeight(.bold)
                    }
                    .font(.subheadline)
                    .frame(maxHeight: 100)
                    
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
                self.poi = nil
                Feedback.selected()
            }) {
                DismissButton()
            })
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .frame(maxWidth: 500)
        .frame(height: 300.0, alignment: .top)
        .cornerRadius(8)
        .shadow(radius: 10)
        
    }
}

// MARK: Previews
struct InfoPoiView_Previews: PreviewProvider {
    
    @State static var poi = PoiManager.shared.pois.first
    
    static var previews: some View {
        
        Group {
            InfoPoiView(poi: $poi)
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
                .previewDisplayName("iPhone 11 Pro Max")
                .environment(\.colorScheme, .dark)
            InfoPoiView(poi: $poi)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (3rd generation)"))
                .previewDisplayName("iPad Pro")
                .environment(\.colorScheme, .light)
            InfoPoiView(poi: $poi)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE")
                .environment(\.colorScheme, .light)
        }
        
    }
}
