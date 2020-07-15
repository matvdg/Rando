//
//  MapView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import UIKit
import MapKit

var currentLayer: Layer?
var selectedAnnotation: PoiAnnotation?
var mapChangedFromUserInteraction = false
var currentPlayingTourState = false
var timer: Timer?

struct MapView: UIViewRepresentable {
    
    // MARK: Binding properties
    @Binding var selectedTracking: Tracking
    @Binding var selectedLayer: Layer
    @Binding var selectedPoi: Poi?
    @Binding var isPlayingTour: Bool
    @Binding var clockwise: Bool
    @Binding var trail: Trail
    
    // MARK: Constructors
    init(selectedTracking: Binding<Tracking>, selectedLayer: Binding<Layer>, selectedPoi: Binding<Poi?>, isPlayingTour: Binding<Bool>, isDetailMap: Bool, clockwise: Binding<Bool>, trail: Binding<Trail>) {
        self._trail = trail
        self._selectedTracking = selectedTracking
        self._selectedLayer = selectedLayer
        self._selectedPoi = selectedPoi
        self._isPlayingTour = isPlayingTour
        self.isDetailMap = isDetailMap
        self._clockwise = clockwise
    }
    
    // Convenience init
    init(trail: Trail) {
        self.init(selectedTracking: Binding<Tracking>.constant(.bounding), selectedLayer: Binding<Layer>.constant(.ign), selectedPoi: Binding<Poi?>.constant(nil), isPlayingTour: Binding<Bool>.constant(false),  isDetailMap: true, clockwise: Binding<Bool>.constant(false), trail: Binding<Trail>.constant(trail))
    }
    
    // MARK: Properties
    var isDetailMap: Bool
    let locationManager = LocationManager.shared
    var annotations: [PoiAnnotation] { PoiManager.shared.pois.map { PoiAnnotation(poi: $0) } }
    var compassY: CGFloat { self.isDetailMap ? 8 : isPlayingTour ? 50 : 160 }
    
    // MARK: Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, HeadingDelegate {
        
        var parent: MapView
        var headingImageView: UIImageView?
        
        init(_ parent: MapView) {
            self.parent = parent
            super.init()
            parent.locationManager.headingDelegate = self
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            mapView.userLocation.subtitle = "Alt. \(Int(parent.locationManager.currentPosition.altitude))m"
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            switch overlay {
            case let overlay as MKTileOverlay:
                return MKTileOverlayRenderer(tileOverlay: overlay)
            default:
                let polylineRenderer = MKPolylineRenderer(overlay: overlay)
                polylineRenderer.strokeColor = .grblue
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
            guard !parent.isPlayingTour, parent.selectedLayer == .ign else { return }
            // Max zoom check
            let coordinate = CLLocationCoordinate2DMake(mapView.region.center.latitude, mapView.region.center.longitude)
            var span = mapView.region.span
            print(span.latitudeDelta)
            let maxZoom: CLLocationDegrees = 0.010
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
        
        func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
            if views.last?.annotation is MKUserLocation {
                addHeadingView(toAnnotationView: views.last!)
            }
        }
        
        func didUpdate(_ heading: CLLocationDirection) {
            guard let headingImageView = headingImageView, parent.selectedTracking == .enabled else { return }
            headingImageView.isHidden = false
            let rotation = CGFloat(heading/180 * Double.pi)
            headingImageView.transform = CGAffineTransform(rotationAngle: rotation)
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
        
        private func addHeadingView(toAnnotationView annotationView: MKAnnotationView) {
            guard headingImageView == nil else { return }
            let image = UIImage(named: "beam")!
            headingImageView = UIImageView(image: image)
            let size: CGFloat = 100
            headingImageView!.frame = CGRect(x: annotationView.frame.size.width/2 - size/2, y: annotationView.frame.size.height/2 - size/2, width: size, height: size)
            annotationView.insertSubview(headingImageView!, at: 0)
            headingImageView!.isHidden = true
        }
        
    }
    
    // MARK: UIViewRepresentable lifecycle methods
    func makeUIView(context: Context) -> MKMapView {
        currentLayer = nil
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        self.configureMap(mapView: mapView)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        playTour(mapView: uiView)
        setTracking(mapView: uiView, headingView: context.coordinator.headingImageView)
        setOverlays(mapView: uiView)
        setAnnotations(mapView: uiView)
    }
    
    // MARK: Private methods
    
    private func configureMap(mapView: MKMapView) {
        mapView.showsTraffic = false
        mapView.showsBuildings = false
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.isPitchEnabled = true
        mapView.addAnnotations(annotations)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            mapView.addOverlay(self.trail.polyline, level: .aboveLabels)
        }
        // Custom compass
        #if !targetEnvironment(macCatalyst)
        mapView.showsCompass = false // Remove default
        let compass = MKCompassButton(mapView: mapView)
        compass.frame = CGRect(origin: CGPoint(x: UIScreen.main.bounds.width - 53, y: compassY), size: CGSize(width: 45, height: 45))
        mapView.addSubview(compass)
        #endif
    }
    
    private func setTracking(mapView: MKMapView, headingView: UIImageView?) {
        switch selectedTracking {
        case .bounding:
            var region = MKCoordinateRegion(trail.polyline.boundingMapRect)
            region.span.latitudeDelta += 0.01
            region.span.longitudeDelta += 0.01
            mapView.setRegion(region, animated: false)
        case .disabled:
            mapView.setUserTrackingMode(.none, animated: true)
            locationManager.updateHeading = false
            headingView?.isHidden = true
        case .enabled:
            mapView.setUserTrackingMode(.follow, animated: true)
            locationManager.updateHeading = true
        case .heading:
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
            headingView?.isHidden = true
        }
    }
    
    private func setOverlays(mapView: MKMapView) {
        // Avoid refreshing UI if selectedLayer has not changed
        guard currentLayer != selectedLayer else { return }
        currentLayer = selectedLayer
        mapView.removeOverlays(mapView.overlays)
        switch selectedLayer {
        case .ign:
            let overlay = TileOverlay()
            overlay.canReplaceMapContent = false
            mapView.mapType = .standard
            mapView.addOverlay(overlay, level: .aboveLabels)
        case .satellite:
            mapView.mapType = .hybrid
        case .flyover:
            mapView.mapType = .hybridFlyover
        default:
            mapView.mapType = .standard
        }
        mapView.addOverlay(trail.polyline, level: .aboveLabels)
    }
    
    private func setAnnotations(mapView: MKMapView) {
        guard selectedPoi == nil else { return }
        mapView.deselectAnnotation(selectedAnnotation, animated: true)
    }
    
    private func playTour(mapView: MKMapView) {
        #if !targetEnvironment(macCatalyst)
        if let compass = mapView.subviews.filter({$0 is MKCompassButton}).first as? MKCompassButton {
            compass.frame.origin.y = compassY
        }
        #endif
        guard isPlayingTour else {
            timer?.invalidate()
            currentPlayingTourState = false
            return
        }
        var locs = trail.locations.map { $0.clLocation.coordinate }
        let animationDuration: TimeInterval = 4
        let altitude: CLLocationDistance = 1000
        if !clockwise {
          locs.reverse()
        }
        let Δ = locs.count / 10
        if currentPlayingTourState {
            timer?.invalidate()
            let camera = MKMapCamera(lookingAtCenter: locs[Δ], fromEyeCoordinate: locs[0], eyeAltitude: altitude)
            camera.pitch = 0
            mapView.camera = camera
        }
        currentPlayingTourState = true
        var i = 0
        guard locs.count > Δ else { return }
        mapView.camera = MKMapCamera(lookingAtCenter: locs[i + Δ], fromEyeCoordinate: locs[i], eyeAltitude: altitude)
        timer = Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: true) { timer in
            i += Δ
            guard i < locs.count else {
                self.isPlayingTour = false
                currentPlayingTourState = false
                return timer.invalidate()
            }
            let camera =  MKMapCamera(lookingAtCenter: locs[i], fromEyeCoordinate: locs[i - Δ], eyeAltitude: altitude)
            camera.pitch = 80
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveLinear, animations: {
                mapView.camera = camera
            })
        }
        
    }
    
}


// MARK: Previews
struct MapView_Previews: PreviewProvider {
    
    static var previews: some View {
        MapView(trail: Trail())
            .previewDevice(PreviewDevice(rawValue: "iPhone X"))
            .previewDisplayName("iPhone X")
            .environment(\.colorScheme, .dark)
    }
}
