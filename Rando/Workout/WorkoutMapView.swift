//
//  MapView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 29/03/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

struct WorkoutMapView: UIViewRepresentable {
    
    @Binding var coordinates: [Location]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polylineOverlay = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(overlay: polylineOverlay)
                renderer.strokeColor = UIColor.grgreen
                renderer.lineWidth = defaultLineWidth
                return renderer
            }
            
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        // Remove any existing overlays
        view.removeOverlays(view.overlays)
        
        // Create a polyline overlay
        let polyline = MKPolyline(coordinates: coordinates.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)}, count: coordinates.count)
        
        // Add the polyline overlay to the map view
        view.addOverlay(polyline)
        
        // Set the visible region of the map to fit the polyline
        let polylineBounds = polyline.boundingMapRect
        var region = MKCoordinateRegion(polylineBounds)
        region.span.latitudeDelta += 0.01
        region.span.longitudeDelta += 0.01
        view.setRegion(region, animated: true)
    }
    
}
