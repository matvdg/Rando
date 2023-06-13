//
//  ItineraryRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 1/08/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
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
            HStack(spacing: 10) {
                Image(systemName: "car")
                Text("Directions")
                    .font(.headline)
            }
        }
        
        .actionSheet(isPresented: $showAlert) {
            ActionSheet(
                title: Text("Directions"),
                buttons: [
                    .default(Text(" Maps"), action: { let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: self.location))
                        mapItem.name = "Departure"
                    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]) }),
                    .default(Text("Waze"), action: { UIApplication.shared.open(URL(string: "https://www.waze.com/ul?ll=\(self.location.latitude)%2C\(self.location.longitude)&navigate=yes")!) }),
                    .default(Text("Google Maps"), action: {
                        UIApplication.shared.open(URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(self.location.latitude),\(self.location.longitude)&travelmode=driving")!)
                    }),
                    .cancel(Text("Cancel"))
                ]
            )
        }
    }
}

// MARK: Previews
struct ItineraryRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ItineraryRow(location: CLLocationCoordinate2D())
            .previewLayout(.fixed(width: 300, height: 80))
            .environment(\.colorScheme, .light)
    }
}
