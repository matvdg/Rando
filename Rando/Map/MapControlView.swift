//
//  MapControlView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 10/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import TipKit

enum Tracking: String {
    case bounding, disabled, enabled, heading
    var icon: String {
        switch self {
        case .enabled: return "location.fill"
        case .heading: return "location.north.line.fill"
        default: return "location"
        }
    }
}

struct MapControlView: View {
    
    let buttonWidth: CGFloat = 22
    let width: CGFloat = 45
    
    @Binding var isLayerViewDisplayed: Bool
    @EnvironmentObject var appManager: AppManager
    
    var body: some View {
        VStack(alignment: .center) {
            if #available(iOS 17.0, *) {
                let layerTip = LayerTip()
                Button(action: {
                    self.isLayerViewDisplayed.toggle()
                    Feedback.selected()
                    layerTip.invalidate(reason: .actionPerformed)
                }) {
                    Image(systemName: isLayerViewDisplayed ? "map.fill" : "map")
                        .resizable()
                        .frame(width: buttonWidth, height: buttonWidth, alignment: .center)
                        .offset(y: -2)
                }
                .popoverTip(layerTip, arrowEdge: .trailing)
            } else {
                // Fallback on earlier versions
                Button(action: {
                    self.isLayerViewDisplayed.toggle()
                    Feedback.selected()
                }) {
                    Image(systemName: isLayerViewDisplayed ? "map.fill" : "map")
                        .resizable()
                        .frame(width: buttonWidth, height: buttonWidth, alignment: .center)
                        .offset(y: -2)
                }
            }
            Divider()
#if !targetEnvironment(macCatalyst)
            if #available(iOS 17.0, *) {
                let mapFullScreenTip = MapFullScreenTip()
                Button(action: {
                    appManager.isMapFullScreen.toggle()
                    Feedback.selected()
                    mapFullScreenTip.invalidate(reason: .actionPerformed)
                }) {
                    Image(appManager.isMapFullScreen ? "iconMapFullScreen" : "iconNotMapFullScreen")
                }
                .popoverTip(mapFullScreenTip, arrowEdge: .trailing)
            } else {
                // Fallback on earlier versions
                Button(action: {
                    appManager.isMapFullScreen.toggle()
                    Feedback.selected()
                }) {
                    Image(appManager.isMapFullScreen ? "iconMapFullScreen" : "iconNotMapFullScreen")
                }
            }
            Divider()
#endif
            if #available(iOS 17.0, *) {
                let boundingTip = BoundingTip()
                Button(action: {
                    appManager.selectedTracking = .bounding
                    Feedback.selected()
                    boundingTip.invalidate(reason: .actionPerformed)
                }) {
                    Image(appManager.selectedTracking == .bounding ? "iconCentered" :  "iconNotCentered")
                }
                .popoverTip(boundingTip, arrowEdge: .trailing)
            } else {
                // Fallback on earlier versions
                Button(action: {
                    appManager.selectedTracking = .bounding
                    Feedback.selected()
                }) {
                    Image(appManager.selectedTracking == .bounding ? "iconCentered" :  "iconNotCentered")
                }
            }
            Divider()
            if #available(iOS 17.0, *) {
                let trackingTip = TrackingTip()
                Button(action: {
                    switch appManager.selectedTracking {
                    case .disabled:
                        appManager.selectedTracking = .enabled
                    case .enabled:
#if targetEnvironment(macCatalyst)
                        appManager.selectedTracking = .disabled
#else
                        appManager.selectedTracking = .heading
#endif
                    case .heading:
                        appManager.selectedTracking = .disabled
                    default:
                        appManager.selectedTracking = .enabled
                    }
                    Feedback.selected()
                    trackingTip.invalidate(reason: .actionPerformed)
                }) {
                    Image(systemName: appManager.selectedTracking.icon)
                        .resizable()
                        .frame(width: appManager.selectedTracking == .heading ? 16 : buttonWidth, height: appManager.selectedTracking == .heading ? 28 : buttonWidth, alignment: .center)
                        .offset(y: 3)
                }
                .popoverTip(trackingTip, arrowEdge: .trailing)
            } else {
                // Fallback on earlier versions
                Button(action: {
                    switch appManager.selectedTracking {
                    case .disabled:
                        appManager.selectedTracking = .enabled
                    case .enabled:
#if targetEnvironment(macCatalyst)
                        appManager.selectedTracking = .disabled
#else
                        appManager.selectedTracking = .heading
#endif
                    case .heading:
                        appManager.selectedTracking = .disabled
                    default:
                        appManager.selectedTracking = .enabled
                    }
                    Feedback.selected()
                }) {
                    Image(systemName: appManager.selectedTracking.icon)
                        .resizable()
                        .frame(width: appManager.selectedTracking == .heading ? 16 : buttonWidth, height: appManager.selectedTracking == .heading ? 28 : buttonWidth, alignment: .center)
                        .offset(y: 3)
                }
            }
        }
#if targetEnvironment(macCatalyst)
        .frame(width: width, height: width*3, alignment: .center)
#else
        .frame(width: width, height: width*4, alignment: .center)
#endif
        .background(Color.alpha)
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

@available(iOS 17.0, *)
struct LayerTip: Tip {

    var title: Text {
        Text("tipLayerTitle")
    }
    
    var message: Text? {
        Text("tipLayerDescription")
    }
    
    var image: Image? {
        Image(systemName: "map.fill")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}

@available(iOS 17.0, *)
struct MapFullScreenTip: Tip {

    var title: Text {
        Text("tipMapFullScreenTitle")
    }
    
    var message: Text? {
        Text("tipMapFullScreenDescription")
    }
    
    var image: Image? {
        Image("iconNotMapFullScreen")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}

@available(iOS 17.0, *)
struct BoundingTip: Tip {

    var title: Text {
        Text("tipBoundingTitle")
    }
    
    var message: Text? {
        Text("tipBoundingDescription")
    }
    
    var image: Image? {
        Image("iconCentered")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}

@available(iOS 17.0, *)
struct TrackingTip: Tip {

    var title: Text {
        Text("tipTrackingTitle")
    }
    
    var message: Text? {
        Text("tipTrackingDescription")
    }
    
    var image: Image? {
        Image(systemName: "location")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}


// MARK: Preview
#Preview {
    MapControlView(isLayerViewDisplayed: .constant(true))
        .environmentObject(AppManager.shared)
}
