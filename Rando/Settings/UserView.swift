//
//  UserView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 02/09/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit


struct UserView: View {
    @State var location: Location
    @State var layer: Layer = .ign25
    var poi: Poi { Poi(lat: location.latitude, lng: location.longitude) }
    
    var body: some View {
        NavigationView {
            MapView(poi: poi, userPosition: location)
                .navigationBarTitle(Text("shareMyPosition"), displayMode: .inline)
                .navigationBarItems(trailing:
                                        Button(action: {
                    Feedback.selected()
                    let window = UIApplication.shared.keyWindow
                    let contentView = ContentView()
                    window?.rootViewController = UIHostingController(rootView: contentView)
                    window?.makeKeyAndVisible()
                }) {
                    DismissButton()
                })
        }
    }
}

#Preview {
    UserView(location: Location(latitude: 42.835191, longitude: 0.872005, altitude: 1944))
}
