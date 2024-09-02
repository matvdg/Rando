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

var selectedAnnotation: PoiAnnotation?
var mapChangedFromUserInteraction = false
var isPlayingTour = false
var timer: Timer?
var isBounding = false

struct MapView: UIViewRepresentable {
    
    // MARK: Binding properties
    @EnvironmentObject var appManager: AppManager
    
    @Binding var selectedPoi: Poi?
    @Binding var clockwise: Bool
    @Binding var trails: [Trail]
    
    var userPositionLocation: Location?
    
    // MARK: Constructors
    init(selectedPoi: Binding<Poi?>, isDetailMap: Bool, clockwise: Binding<Bool>, trails: Binding<[Trail]>, userPositionLocation: Location? = nil) {
        self._trails = trails
        self._selectedPoi = selectedPoi
        self.isDetailMap = isDetailMap
        self._clockwise = clockwise
        self.userPositionLocation = userPositionLocation
    }
    
    /// Convenience init for  TrailDetail map
    init(trail: Trail) {
        self.init(
            selectedPoi: Binding<Poi?>.constant(nil),
            isDetailMap: true,
            clockwise: Binding<Bool>.constant(false),
            trails: Binding<[Trail]>.constant([trail])
        )
        isBounding = true
    }
    
    /// Convenience init for  PoiDetail map
    init(poi: Poi) {
        self.init(
            selectedPoi: Binding<Poi?>.constant(poi),
            isDetailMap: true,
            clockwise: Binding<Bool>.constant(false),
            trails: Binding<[Trail]>.constant([poi.pseudoTrail])
        )
        isBounding = true
    }
    
    /// Convenience init for  UserPosition  map
    init(poi: Poi, userPosition: Location) {
        self.init(
            selectedPoi: Binding<Poi?>.constant(nil),
            isDetailMap: true,
            clockwise: Binding<Bool>.constant(false),
            trails: Binding<[Trail]>.constant([poi.pseudoTrail]),
            userPositionLocation: userPosition
        )
        isBounding = false
    }
    
    /// Convenience init for  HomeView map
    init(selectedPoi: Binding<Poi?>, trails: Binding<[Trail]>) {
        self.init(
            selectedPoi: selectedPoi,
            isDetailMap: false,
            clockwise: Binding<Bool>.constant(false),
            trails: trails
        )
        isBounding = false
    }
    
    /// Convenience init for  TourView map
    init(clockwise: Binding<Bool>, trail: Trail) {
        self.init(
            selectedPoi: Binding<Poi?>.constant(nil),
            isDetailMap: true,
            clockwise: clockwise,
            trails: Binding<[Trail]>.constant([trail])
        )
        isBounding = false
    }
    
    // MARK: Properties
    var isDetailMap: Bool
    let locationManager = LocationManager.shared
    var annotations: [PoiAnnotation] {
        PoiManager.shared.pois.map { PoiAnnotation(poi: $0) }
            .filter {
                switch appManager.selectedCategory {
                case .peak: return $0.poi.category == .peak
                case .refuge: return $0.poi.category == .refuge
                case .waterfall: return $0.poi.category == .waterfall
                case .lake: return $0.poi.category == .lake
                case .shelter: return $0.poi.category == .shelter
                case .shop: return $0.poi.category == .shop
                case .all: return true
                case .none: return false
                default: return $0.poi.category == .pov || $0.poi.category == .bridge || $0.poi.category == .camping || $0.poi.category == .dam || $0.poi.category == .spring || $0.poi.category == .pass || $0.poi.category == .parking
                }
            }
    }
    
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
            mapView.userLocation.title = "Alt. \(Int(parent.locationManager.currentPosition.altitude))m"
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            switch overlay {
            case let overlay as MKTileOverlay:
                return MKTileOverlayRenderer(tileOverlay: overlay)
            case let polyline as Polyline:
                let polylineRenderer = MKPolylineRenderer(overlay: overlay)
                polylineRenderer.strokeColor = polyline.color ?? .grblue
                polylineRenderer.lineWidth = polyline.lineWidth ?? defaultLineWidth
                return polylineRenderer
            default: return MKOverlayRenderer()
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let annotation = annotation as? PoiAnnotation {
                let identifier = "Annotation"
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                if let view = view {
                    view.annotation = annotation
                } else {
                    view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view?.canShowCallout = true
                }
                if let view = view as? MKMarkerAnnotationView {
                    view.glyphImage = annotation.poi.category.image
                    view.markerTintColor = annotation.markerColor
                }
                return view
            } else if let annotation = annotation as? MKUserLocation {
                    let identifier = "User"
                    var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                    if let view = view {
                        view.annotation = annotation
                    } else {
                        view = MKUserLocationView(annotation: annotation, reuseIdentifier: identifier)
                    }
                    if let view = view as? MKUserLocationView {
                        view.canShowCallout = true
                        view.detailCalloutAccessoryView = UILabel()
                    }
                    return view
            } else {
                return nil
            }
        }
        
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction(mapView)
            if mapChangedFromUserInteraction {
                parent.appManager.selectedTracking = .disabled
                isBounding = false
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? PoiAnnotation, !parent.isDetailMap else {
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
            if let userAnnotationView = views.first(where: { $0 is MKUserLocationView}) {
                addHeadingView(toAnnotationView: userAnnotationView)
            }
        }
        
        func didUpdate(_ heading: CLLocationDirection) {
            guard let headingImageView = headingImageView, parent.appManager.selectedTracking == .enabled else { return }
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
            headingImageView?.tintColor = .grblue
            let size: CGFloat = 100
            headingImageView!.frame = CGRect(x: annotationView.frame.size.width/2 - size/2, y: annotationView.frame.size.height/2 - size/2, width: size, height: size)
            annotationView.insertSubview(headingImageView!, at: 0)
            headingImageView!.isHidden = true
        }
        
    }
    
    // MARK: UIViewRepresentable lifecycle methods
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        self.configureMap(mapView: mapView)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        setTracking(mapView: uiView, headingView: context.coordinator.headingImageView)
        setOverlays(mapView: uiView)
        setAnnotations(mapView: uiView)
        guard isPlayingTour else { return }
        self.playTour(mapView: uiView)
    }
    
    // MARK: Private methods
    
    private func configureMap(mapView: MKMapView) {
        mapView.showsTraffic = false
        mapView.showsBuildings = false
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.tintColor = .grblue
        mapView.isPitchEnabled = true
        mapView.showsCompass = true // Remove default
    }
    
    private func setTracking(mapView: MKMapView, headingView: UIImageView?) {
        let tracking: Tracking = isBounding ? .bounding : appManager.selectedTracking
        switch tracking {
        case .bounding:
            guard let firstBoundingBox = trails.first?.polyline.boundingMapRect else {
                appManager.selectedTracking = .enabled
                isBounding = false
                return
            }
            let boundingBox = trails
                .map { $0.polyline.boundingMapRect }
                .reduce(firstBoundingBox) { (boundingBox, nextResult) -> MKMapRect in
                    let minX = nextResult.minX < boundingBox.minX ? nextResult.minX : boundingBox.minX
                    let maxX = nextResult.maxX > boundingBox.maxX ? nextResult.maxX : boundingBox.maxX
                    let minY = nextResult.minY < boundingBox.minY ? nextResult.minY : boundingBox.minY
                    let maxY = nextResult.maxY > boundingBox.maxY ? nextResult.maxY : boundingBox.maxY
                    return MKMapRect(origin: MKMapPoint(x: minX, y: minY), size: MKMapSize(width: maxX-minX, height: maxY-minY))
            }
            var region = MKCoordinateRegion(boundingBox)
            region.span.latitudeDelta += 0.01
            region.span.longitudeDelta += 0.01
            mapView.setRegion(region, animated: false)
        case .disabled:
            mapView.setUserTrackingMode(.none, animated: true)
            locationManager.updateHeading = false
            headingView?.isHidden = true
            isBounding = false
        case .enabled:
            mapView.setUserTrackingMode(.follow, animated: true)
            locationManager.updateHeading = true
            headingView?.isHidden = false
            isBounding = false
        case .heading:
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
            headingView?.isHidden = true
            isBounding = false
        }
    }
    
    private func setOverlays(mapView: MKMapView) {
        let currentTileOverlay = mapView.overlays.first { $0 is MKTileOverlay}
        let currentPolylines = mapView.overlays.compactMap { $0 as? Polyline }
        var layerHasChanged: Bool
        switch appManager.selectedLayer {
        case .ign25:
            layerHasChanged = !(currentTileOverlay is IGN25Overlay)
        case .ign:
            layerHasChanged = !(currentTileOverlay is IGNV2Overlay)
        case .standard:
            layerHasChanged = !(mapView.mapType == .standard)
        case .satellite:
            layerHasChanged = !(mapView.mapType == .hybrid)
        case .flyover:
            layerHasChanged = !(mapView.mapType == .hybridFlyover)
        case .openStreetMap:
            layerHasChanged = !(currentTileOverlay is OpenStreetMapOverlay)
        case .openTopoMap:
            layerHasChanged = !(currentTileOverlay is OpenTopoMapOverlay)
        case .swissTopo:
            layerHasChanged = !(currentTileOverlay is SwissTopoMapOverlay)
        }
        let polylines = trails.map { $0.polyline }
        let polylinesHaveChanged = !currentPolylines.equals(polylines: polylines)
        guard polylinesHaveChanged || layerHasChanged else { return }
        mapView.removeOverlays(mapView.overlays)
        switch appManager.selectedLayer {
        case .satellite:
            mapView.mapType = .hybrid
        case .flyover:
            mapView.mapType = .hybridFlyover
        case .standard:
            mapView.mapType = .standard
        default:
            let overlay: MKTileOverlay
            switch appManager.selectedLayer {
            case .ign25:
                overlay = IGN25Overlay()
            case .openStreetMap:
                overlay = OpenStreetMapOverlay()
            case .openTopoMap:
                overlay = OpenTopoMapOverlay()
            case .swissTopo:
                overlay = SwissTopoMapOverlay()
            default: //ign
                overlay = IGNV2Overlay()
            }
            overlay.canReplaceMapContent = false
            mapView.mapType = .mutedStandard // Other type underneath the overlay not used in standard/hybrid/hybridFlyover cases to track changes
            mapView.addOverlay(overlay, level: .aboveLabels)
        }
        mapView.addOverlays(polylines, level: .aboveLabels)
    }
    
    private func setAnnotations(mapView: MKMapView) {
        if let userPositionLocation {
            let annotation = MKPointAnnotation()
            annotation.coordinate = userPositionLocation.clLocation.coordinate
            mapView.addAnnotation(annotation)
        } else {
            let previousAnnotations = mapView.annotations
            if previousAnnotations.count != annotations.count + 1 {
                mapView.removeAnnotations(previousAnnotations)
                mapView.addAnnotations(annotations)
            } else {
                guard selectedPoi == nil else { return }
                mapView.deselectAnnotation(selectedAnnotation, animated: true)
            }
        }
    }
    
    private func playTour(mapView: MKMapView) {
        timer?.invalidate()
        var locs = trails.first!.locations.map { $0.clLocation.coordinate }
        let animationDuration: TimeInterval = 4
        let altitude: CLLocationDistance = 1000
        if !clockwise {
            locs.reverse()
        }
        let Δ = locs.count / 10
        var i = 0
        mapView.camera = MKMapCamera(lookingAtCenter: locs[i + Δ], fromEyeCoordinate: locs[i], eyeAltitude: altitude)
        timer = Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: true) { timer in
            i += Δ
            guard i < locs.count else {
                isPlayingTour = false
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
            .environmentObject(AppManager.shared)
    }
}

extension Array where Iterator.Element == Polyline {
    
    func equals(polylines: [Polyline]) -> Bool {
        let currentArray: [Polyline] = self
        if self.count == polylines.count {
            return polylines.elementsEqual(currentArray) { $0.isEqual(polyline: $1) }
        } else {
            return false
        }
    }
    
}
