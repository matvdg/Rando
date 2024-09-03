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
                var layerTip = LayerTip()
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
            if #available(iOS 17.0, *) {
                var lockTip = LockTip()
                Button(action: {
                    appManager.isLocked.toggle()
                    Feedback.selected()
                    lockTip.invalidate(reason: .actionPerformed)
                }) {
                    Image(systemName: appManager.isLocked ? "lock" : "lock.open")
                        .resizable()
                        .frame(width: buttonWidth, height: buttonWidth)
                    
                }
                .popoverTip(LockTip(), arrowEdge: .trailing)
            } else {
                // Fallback on earlier versions
                Button(action: {
                    appManager.isLocked.toggle()
                    Feedback.selected()
                }) {
                    Image(systemName: appManager.isLocked ? "lock" : "lock.open")
                        .resizable()
                        .frame(width: buttonWidth, height: buttonWidth)
                    
                }
            }
            Divider()
            if #available(iOS 17.0, *) {
                var boundingTip = BoundingTip()
                Button(action: {
                    appManager.selectedTracking = .bounding
                    Feedback.selected()
                    boundingTip.invalidate(reason: .actionPerformed)
                }) {
                    Image(systemName: appManager.selectedTracking == .bounding ? "inset.filled.center.rectangle" :  "camera.metering.center.weighted.average")
                        .resizable()
                        .frame(width: buttonWidth, height: buttonWidth)
                    
                }
                .popoverTip(BoundingTip(), arrowEdge: .trailing)
            } else {
                // Fallback on earlier versions
                Button(action: {
                    appManager.selectedTracking = .bounding
                    Feedback.selected()
                }) {
                    Image(systemName: appManager.selectedTracking == .bounding ? "inset.filled.center.rectangle" :  "camera.metering.center.weighted.average")
                        .resizable()
                        .frame(width: buttonWidth, height: buttonWidth)
                    
                }
            }
            Divider()
            if #available(iOS 17.0, *) {
                var trackingTip = TrackingTip()
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
                .popoverTip(TrackingTip(), arrowEdge: .trailing)
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
        .frame(width: width, height: width*4, alignment: .center)
        .background(Color.alpha)
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

@available(iOS 17.0, *)
struct LayerTip: Tip {

    var title: Text {
        Text("TipLayerTitle")
    }
    
    var message: Text? {
        Text("TipLayerDescription")
    }
    
    var image: Image? {
        Image(systemName: "map.fill")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}

@available(iOS 17.0, *)
struct LockTip: Tip {

    var title: Text {
        Text("TipLockTitle")
    }
    
    var message: Text? {
        Text("TipLockDescription")
    }
    
    var image: Image? {
        Image(systemName: "lock.fill")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}

@available(iOS 17.0, *)
struct BoundingTip: Tip {

    var title: Text {
        Text("TipBoundingTitle")
    }
    
    var message: Text? {
        Text("TipBoundingDescription")
    }
    
    var image: Image? {
        Image(systemName: "camera.metering.center.weighted.average")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}

@available(iOS 17.0, *)
struct TrackingTip: Tip {

    var title: Text {
        Text("TipTrackingTitle")
    }
    
    var message: Text? {
        Text("TipTrackingDescription")
    }
    
    var image: Image? {
        Image(systemName: "location")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}


// MARK: Previews
struct MapControl_Previews: PreviewProvider {
    @State static var isLayerViewDisplayed = false
    static var previews: some View {
        MapControlView(isLayerViewDisplayed: $isLayerViewDisplayed)
            .environmentObject(AppManager.shared)
            .previewLayout(.fixed(width: 60, height: 135))
    }
}
