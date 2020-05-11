//
//  MapView.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import UIKit
import MapKit


struct MapView: UIViewRepresentable {
  
  @Binding var isCentered: Bool
  @Binding var selectedDisplayMode: Int
  
  var poiCoordinate: CLLocationCoordinate2D?
 
  let gpxManager = GpxManager.shared
  let poiManager = PoiManager.shared
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, MKMapViewDelegate {
    
    var parent: MapView
    
    init(_ parent: MapView) {
      self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
      mapView.userLocation.subtitle = "Alt. \(Int(LocationManager.shared.currentPosition.altitude))m"
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      switch overlay {
      case let overlay as MKTileOverlay:
        return MKTileOverlayRenderer(tileOverlay: overlay)
      default:
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = .gred
        polylineRenderer.lineWidth = 3
        return polylineRenderer
      }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      guard let annotation = annotation as? PoiAnnotation else { return nil }
      let identifier = "Annotation"
      var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
      if let view = view {
        view.annotation = annotation
      } else {
        view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view?.canShowCallout = true
      }
      if let view = view as? MKMarkerAnnotationView {
        view.glyphImage = annotation.markerGlyph
        view.markerTintColor = annotation.markerColor
      }
      return view
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
      guard !animated else { return }
      self.parent.isCentered = false
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
      // Max zoom check
      let coordinate = CLLocationCoordinate2DMake(mapView.region.center.latitude, mapView.region.center.longitude)
      var span = mapView.region.span
      let maxZoom: CLLocationDegrees = 0.014
      if span.latitudeDelta < maxZoom {
        span = MKCoordinateSpan(latitudeDelta: maxZoom, longitudeDelta: maxZoom)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
      }
    }
    
  }
  
  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    self.configureMap(mapView: mapView)
    return mapView
  }
  
  func updateUIView(_ uiView: MKMapView, context: Context) {
    uiView.setUserTrackingMode(isCentered ? .follow : .none, animated: true)
    setOverlays(mapView: uiView)
  }
  
  private func configureMap(mapView: MKMapView) {
    setOverlays(mapView: mapView)
    if let coordinate = poiCoordinate { // MiniMap for POI
      let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
      let region = MKCoordinateRegion(center: coordinate, span: span)
      mapView.setRegion(region, animated: true)
      mapView.showsScale = false
      mapView.showsCompass = false
      mapView.isUserInteractionEnabled = false
    } else { // Home map
      
      let pois = poiManager.annotations
      mapView.addAnnotations(pois)
      mapView.layoutMargins = UIEdgeInsets(top: 100, left: 14, bottom: -100, right: 15)
      let region = MKCoordinateRegion(gpxManager.boundingBox)
      mapView.setRegion(region, animated: false)
      mapView.showsScale = true
      mapView.showsCompass = true
      mapView.isUserInteractionEnabled = true
    }
    mapView.showsTraffic = false
    mapView.showsBuildings = false
    mapView.showsUserLocation = true
  }
  
  private func setOverlays(mapView: MKMapView) {
    mapView.removeOverlays(mapView.overlays)
    switch selectedDisplayMode {
    case InfoView.DisplayMode.ign.rawValue:
      let overlay = TileOverlay()
      overlay.canReplaceMapContent = false
      mapView.mapType = .standard
      mapView.addOverlay(overlay, level: .aboveLabels)
    case InfoView.DisplayMode.satellite.rawValue:
      mapView.mapType = .hybrid
    default:
      mapView.mapType = .standard
    }
    mapView.addOverlay(gpxManager.polyline, level: .aboveLabels)
  }
}


struct MapView_Previews: PreviewProvider {
  @State static var isCentered: Bool = false
  @State static var selectedDisplayMode: Int = 0
  static var previews: some View {
    MapView(isCentered: $isCentered, selectedDisplayMode: $selectedDisplayMode)
      .previewDevice(PreviewDevice(rawValue: "iPhone X"))
      .previewDisplayName("iPhone X")
      .environment(\.colorScheme, .dark)
  }
}
