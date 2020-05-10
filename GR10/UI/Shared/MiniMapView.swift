//
//  MiniMapView.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

struct MiniMapView: UIViewRepresentable {
  
  var coordinate: CLLocationCoordinate2D
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, MKMapViewDelegate {
    
    var parent: MiniMapView
    
    init(_ parent: MiniMapView) {
      self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      guard let overlay = overlay as? MKTileOverlay else { return MKOverlayRenderer() }
      return MKTileOverlayRenderer(tileOverlay: overlay)
    }
    
  }
  
  func makeUIView(context: Context) -> MKMapView {
    MKMapView(frame: .zero)
  }
  
  func updateUIView(_ uiView: MKMapView, context: Context) {
    let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    let region = MKCoordinateRegion(center: coordinate, span: span)
    uiView.setRegion(region, animated: true)
    let overlay = TileOverlay()
    overlay.canReplaceMapContent = true
    uiView.addOverlay(overlay, level: .aboveRoads)
    uiView.delegate = context.coordinator
  }
}

struct MiniMapView_Previews: PreviewProvider {
  static var previews: some View {
    return MiniMapView(coordinate: pois[0].coordinates)
      .previewDevice(PreviewDevice(rawValue: "iPhone X"))
      .previewDisplayName("iPhone X")
      .environment(\.colorScheme, .light)
  }
}
