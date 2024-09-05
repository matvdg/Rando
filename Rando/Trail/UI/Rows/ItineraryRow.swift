//
//  ItineraryRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 1/08/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

struct ItineraryRow: View {
    
    @State private var showAlert = false
    
    var location: CLLocationCoordinate2D
    
    var body: some View {
        
        Button(action: {
            Feedback.selected()
            self.showAlert.toggle()
        }) {
            Label("directions", systemImage: "car")
        }
        .actionSheet(isPresented: $showAlert) {
            ActionSheet(
                title: Text("directions"),
                buttons: [
                    .default(Text("appleMaps"), action: { let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: self.location))
                        mapItem.name = "departure"
                    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]) }),
                    .default(Text("waze"), action: { UIApplication.shared.open(URL(string: "https://www.waze.com/ul?ll=\(self.location.latitude)%2C\(self.location.longitude)&navigate=yes")!) }),
                    .default(Text("waze"), action: { UIApplication.shared.open(URL(string: "https://www.waze.com/ul?ll=\(self.location.latitude)%2C\(self.location.longitude)&navigate=yes")!) }),
                    .default(Text("gmaps"), action: {
                        UIApplication.shared.open(URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(self.location.latitude),\(self.location.longitude)&travelmode=driving")!)
                    }),
                    .cancel(Text("cancel"))
                ]
            )
        }
    }
}

// MARK: Preview
#Preview {
    ItineraryRow(location: CLLocationCoordinate2D())
}
