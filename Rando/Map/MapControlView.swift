//
//  MapControlView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 10/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

enum Tracking {
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
    @Binding var tracking: Tracking
    @Binding var isLayerViewDisplayed: Bool
    @Binding var isLocked: Bool
    
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
                self.isLocked.toggle()
                Feedback.selected()
            }) {
                Image(systemName: isLocked ? "lock" : "lock.open")
                    .resizable()
                    .frame(width: isLocked ? 15 : buttonWidth, height: buttonWidth)
                
            }
            Divider()
            Button(action: {
                switch self.tracking {
                case .disabled:
                    self.tracking = .enabled
                case .enabled:
#if targetEnvironment(macCatalyst)
                    self.tracking = .disabled
#else
                    self.tracking = .heading
#endif
                case .heading:
                    self.tracking = .disabled
                default:
                    self.tracking = .enabled
                }
                Feedback.selected()
            }) {
                Image(systemName: tracking.icon)
                    .resizable()
                    .frame(width: tracking == .heading ? 16 : buttonWidth, height: tracking == .heading ? 28 : buttonWidth, alignment: .center)
                    .offset(y: 3)
            }
        }
        .frame(width: width, height: width*3, alignment: .center)
        .background(Color.alpha)
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

// MARK: Previews
struct MapControl_Previews: PreviewProvider {
    @State static var tracking: Tracking = .disabled
    @State static var isInfoDisplayed = false
    @State static var isLocked = false
    static var previews: some View {
        MapControlView(tracking: $tracking, isLayerViewDisplayed: $isInfoDisplayed, isLocked: $isLocked)
            .previewLayout(.fixed(width: 60, height: 135))
    }
}
