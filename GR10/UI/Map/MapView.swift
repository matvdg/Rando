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

var currentDisplayMode = -1
var selectedAnnotation: PoiAnnotation?

struct MapView: UIViewRepresentable {
  
  // MARK: Binding properties
  @Binding var isCentered: Bool
  @Binding var selectedDisplayMode: Int
  @Binding var selectedPoi: Poi?
  
  // MARK: Constructors
  init(isCentered: Binding<Bool>, selectedDisplayMode: Binding<Int>, selectedPoi: Binding<Poi?>, poiCoordinate: CLLocationCoordinate2D? = nil) {
    
    self.poiCoordinate = poiCoordinate
    self._isCentered = isCentered
    self._selectedDisplayMode = selectedDisplayMode
    self._selectedPoi = selectedPoi
    
  }
  
  // Convenience init
  init(poiCoordinate: CLLocationCoordinate2D? = nil) {
    
    self.init(isCentered: Binding<Bool>.constant(false), selectedDisplayMode: Binding<Int>.constant(0), selectedPoi: Binding<Poi?>.constant(nil), poiCoordinate: poiCoordinate)
    
  }
  
  // MARK: Properties
  var poiCoordinate: CLLocationCoordinate2D?
 
  let gpxManager = GpxManager.shared
  let poiManager = PoiManager.shared
  
  // MARK: Coordinator
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      guard let annotation = view.annotation as? PoiAnnotation else {
        return }
      self.parent.selectedPoi = annotation.poi
      selectedAnnotation = annotation
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
      self.parent.selectedPoi = nil
      selectedAnnotation = nil
    }
    
  }
  
  // MARK: UIViewRepresentable lifecycle methods
  func makeUIView(context: Context) -> MKMapView {
    currentDisplayMode = -1
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    self.configureMap(mapView: mapView)
    return mapView
  }
  
  func updateUIView(_ uiView: MKMapView, context: Context) {
    uiView.setUserTrackingMode(isCentered ? .follow : .none, animated: true)
    setOverlays(mapView: uiView)
    if selectedPoi == nil {
      uiView.deselectAnnotation(selectedAnnotation, animated: true)
    }
  }
    
  // MARK: Private methods
  private func configureMap(mapView: MKMapView) {
    setOverlays(mapView: mapView)
    if let coordinate = poiCoordinate { // MiniMap for POI
      let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
      let region = MKCoordinateRegion(center: coordinate, span: span)
      mapView.setRegion(region, animated: true)
    } else { // Home map
      let pois = poiManager.annotations
      mapView.addAnnotations(pois)
      let region = MKCoordinateRegion(gpxManager.boundingBox)
      mapView.setRegion(region, animated: false)
    }
    mapView.showsTraffic = false
    mapView.showsBuildings = false
    mapView.showsUserLocation = true
    mapView.showsScale = true
    // Custom compass
    mapView.showsCompass = false // Remove default
    let compass = MKCompassButton(mapView: mapView)
    compass.frame = CGRect(origin: CGPoint(x: UIScreen.main.bounds.width - 53, y: 110), size: CGSize(width: 45, height: 45))
    mapView.addSubview(compass)
  }
  
  private func setOverlays(mapView: MKMapView) {
    // Avoid refreshing UI if selectedDisplayMode has not changed
    guard selectedDisplayMode != currentDisplayMode else { return }
    currentDisplayMode = selectedDisplayMode
    mapView.removeOverlays(mapView.overlays)
    switch selectedDisplayMode {
    case InfoView.DisplayMode.IGN.rawValue:
      let overlay = TileOverlay()
      overlay.canReplaceMapContent = false
      mapView.mapType = .standard
      mapView.addOverlay(overlay, level: .aboveLabels)
    case InfoView.DisplayMode.Satellite.rawValue:
      mapView.mapType = .hybrid
    default:
      mapView.mapType = .standard
    }
    mapView.addOverlay(gpxManager.polyline, level: .aboveLabels)
  }
}


// MARK: Previews
struct MapView_Previews: PreviewProvider {
  
  static var previews: some View {
    MapView()
      .previewDevice(PreviewDevice(rawValue: "iPhone X"))
      .previewDisplayName("iPhone X")
      .environment(\.colorScheme, .dark)
  }
}
