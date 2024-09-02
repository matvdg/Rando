//
//  MapControlView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 10/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

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
            Button(action: {
                self.isLayerViewDisplayed.toggle()
                Feedback.selected()
            }) {
                Image(systemName: isLayerViewDisplayed ? "map.fill" : "map")
                    .resizable()
                    .frame(width: buttonWidth, height: buttonWidth, alignment: .center)
                    .offset(y: -2)
            }
            Divider()
            Button(action: {
                appManager.isLocked.toggle()
                Feedback.selected()
            }) {
                Image(systemName: appManager.isLocked ? "lock" : "lock.open")
                    .resizable()
                    .frame(width: buttonWidth, height: buttonWidth)
                
            }
            Divider()
            Button(action: {
                appManager.selectedTracking = .bounding
                Feedback.selected()
            }) {
                Image(systemName: appManager.selectedTracking == .bounding ? "inset.filled.center.rectangle" :  "camera.metering.center.weighted.average")
                    .resizable()
                    .frame(width: buttonWidth, height: buttonWidth)
                
            }
            Divider()
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
        .frame(width: width, height: width*4, alignment: .center)
        .background(Color.alpha)
        .cornerRadius(8)
        .shadow(radius: 1)
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
