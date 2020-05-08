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

var boundingBox = MKMapRect()
var coordinate = CLLocationCoordinate2D(latitude: 42.835191, longitude: 0.872005) // Etang d'Araing

struct MapView: UIViewRepresentable {
  
  
  let gpxRepository = GpxRepository.shared
  let poiRepository = PoiRepository.shared
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, MKMapViewDelegate {
    
    var parent: MapView
    
    init(_ parent: MapView) {
      self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      switch overlay {
      case let overlay as MKTileOverlay:
        return MKTileOverlayRenderer(tileOverlay: overlay)
      default:
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = .red
        polylineRenderer.lineWidth = 3
        return polylineRenderer
      }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      guard annotation is MKPointAnnotation else { return nil }
      
      let identifier = "Annotation"
      var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
      
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView!.canShowCallout = true
      } else {
        annotationView!.annotation = annotation
      }
      
      return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
      self.setRegion(mapView: mapView)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
      self.setRegion(mapView: mapView)
    }
    
    private func setRegion(mapView: MKMapView) {
      let newCoordinate = CLLocationCoordinate2DMake(mapView.region.center.latitude, mapView.region.center.longitude)
      var span = mapView.region.span
      let maxZoom: CLLocationDegrees = 0.014
      if boundingBox.contains(MKMapPoint(newCoordinate)) {
        coordinate = newCoordinate
      }
      let minZoom: CLLocationDegrees = 2
      if span.latitudeDelta < maxZoom {
        span = MKCoordinateSpan(latitudeDelta: maxZoom, longitudeDelta: maxZoom)
      } else if span.latitudeDelta > minZoom {
        span = MKCoordinateSpan(latitudeDelta: minZoom, longitudeDelta: minZoom)
      }
      let region = MKCoordinateRegion(center: coordinate, span: span)
      mapView.setRegion(region, animated: false)
    }
    
  }
  
  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    self.configureMap(mapView: mapView)
    return mapView
  }
  
  func updateUIView(_ uiView: MKMapView, context: Context) {}
  
  private func configureMap(mapView: MKMapView) {
    let overlay = TileOverlay()
    overlay.canReplaceMapContent = true
    mapView.addOverlay(overlay, level: .aboveRoads)
    let coordinate = CLLocationCoordinate2D(
      latitude: 42.960008, longitude: -0.28645)
    let span = MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
    let gr10 = gpxRepository.polyline
    boundingBox = gr10.boundingMapRect
    mapView.addOverlay(gr10)
    mapView.showsScale = true
    mapView.showsCompass = true
    mapView.showsTraffic = false
    mapView.showsBuildings = false
    mapView.showsUserLocation = true
    let region = MKCoordinateRegion(center: coordinate, span: span)
    mapView.setRegion(region, animated: false)
    let pois = poiRepository.annotations
    mapView.addAnnotations(pois)
  }
}



struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView()
      .previewDevice(PreviewDevice(rawValue: "iPhone X"))
      .previewDisplayName("iPhone X")
      .environment(\.colorScheme, .dark)
  }
}
