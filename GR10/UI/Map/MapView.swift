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

var currentLayer: Layer?
var currentFilter: Filter?
var selectedAnnotation: PoiAnnotation?
var mapChangedFromUserInteraction = false

struct MapView: UIViewRepresentable {
  
  // MARK: Binding properties
  @Binding var selectedTracking: Tracking
  @Binding var selectedLayer: Layer
  @Binding var selectedFilter: Filter
  @Binding var selectedPoi: Poi?
  
  // MARK: Constructors
  init(selectedTracking: Binding<Tracking>, selectedLayer: Binding<Layer>, selectedFilter: Binding<Filter>, selectedPoi: Binding<Poi?>, poiCoordinate: CLLocationCoordinate2D? = nil) {
    
    self.poiCoordinate = poiCoordinate
    self._selectedTracking = selectedTracking
    self._selectedLayer = selectedLayer
    self._selectedPoi = selectedPoi
    self._selectedFilter = selectedFilter
    
  }
  
  // Convenience init
  init(poiCoordinate: CLLocationCoordinate2D? = nil) {
    
    self.init(selectedTracking: Binding<Tracking>.constant(.disabled), selectedLayer: Binding<Layer>.constant(.IGN), selectedFilter: Binding<Filter>.constant(.all), selectedPoi: Binding<Poi?>.constant(nil), poiCoordinate: poiCoordinate)
    
  }
  
  // MARK: Properties
  var poiCoordinate: CLLocationCoordinate2D?
  let gpxManager = GpxManager.shared
  
  var annotations: [PoiAnnotation] {
    var selectedPois: [Poi]
    switch selectedFilter {
    case .all: selectedPois =  pois
    case .refuge: selectedPois =  pois.filter { $0.category == .refuge }
    case .peak: selectedPois =  pois.filter { $0.category == .peak }
    default: selectedPois = pois.filter { $0.category == .waterfall }
    }
    return selectedPois.map { PoiAnnotation(poi: $0) }
  }
  
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
      mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction(mapView)
      if mapChangedFromUserInteraction {
        self.parent.selectedTracking = .disabled
      }
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
      Feedback.selected()
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
      self.parent.selectedPoi = nil
      selectedAnnotation = nil
      Feedback.selected()
    }
    
    private func mapViewRegionDidChangeFromUserInteraction(_ mapView: MKMapView) -> Bool {
      let view = mapView.subviews[0]
      //  Look through gesture recognizers to determine whether this region change is from user interaction
      if let gestureRecognizers = view.gestureRecognizers {
        for recognizer in gestureRecognizers {
          if recognizer.state == .began || recognizer.state == .ended {
            return true
          }
        }
      }
      return false
    }
    
  }
  
  // MARK: UIViewRepresentable lifecycle methods
  func makeUIView(context: Context) -> MKMapView {
    currentLayer = nil
    currentFilter = nil
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    self.configureMap(mapView: mapView)
    return mapView
  }
  
  func updateUIView(_ uiView: MKMapView, context: Context) {
    switch selectedTracking {
    case .disabled: uiView.setUserTrackingMode(.none, animated: true)
    case .enabled: uiView.setUserTrackingMode(.follow, animated: true)
    case .heading: uiView.setUserTrackingMode(.followWithHeading, animated: true)
    }
    setOverlays(mapView: uiView)
    setAnnotations(mapView: uiView)
    if selectedPoi == nil {
      uiView.deselectAnnotation(selectedAnnotation, animated: true)
    }
  }
  
  // MARK: Private methods
  private func configureMap(mapView: MKMapView) {
    setOverlays(mapView: mapView)
    setAnnotations(mapView: mapView)
    mapView.showsTraffic = false
    mapView.showsBuildings = false
    mapView.showsUserLocation = true
    mapView.showsScale = true
    mapView.isPitchEnabled = true
    // Custom compass
    mapView.showsCompass = false // Remove default
    let compass = MKCompassButton(mapView: mapView)
    compass.frame = CGRect(origin: CGPoint(x: UIScreen.main.bounds.width - 53, y: poiCoordinate == nil ? 160 : 8), size: CGSize(width: 45, height: 45))
    mapView.addSubview(compass)
  }
  
  private func setOverlays(mapView: MKMapView) {
    // Avoid refreshing UI if selectedLayer has not changed
    guard currentLayer != selectedLayer else { return }
    currentLayer = selectedLayer
    mapView.removeOverlays(mapView.overlays)
    switch selectedLayer {
    case .IGN:
      let overlay = TileOverlay()
      overlay.canReplaceMapContent = false
      mapView.mapType = .standard
      mapView.addOverlay(overlay, level: .aboveLabels)
    case .Satellite:
      mapView.mapType = .hybrid
    case .Flyover:
      mapView.mapType = .hybridFlyover
    default:
      mapView.mapType = .standard
    }
    mapView.addOverlay(gpxManager.polyline, level: .aboveLabels)
  }
  
  private func setAnnotations(mapView: MKMapView) {
    // Avoid refreshing UI if selectedFilter has not changed
    guard currentFilter != selectedFilter else { return }
    currentFilter = selectedFilter
    mapView.removeAnnotations(mapView.annotations)
    if let coordinate = poiCoordinate { // MiniMap for POI
      let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
      let region = MKCoordinateRegion(center: coordinate, span: span)
      mapView.setRegion(region, animated: true)
    } else { // Home map
      mapView.addAnnotations(annotations)
      let region = MKCoordinateRegion(gpxManager.boundingBox)
      mapView.setRegion(region, animated: false)
    }
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
