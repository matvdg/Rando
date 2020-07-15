//
//  MapControl.swift
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

struct MapControl: View {
  let buttonWidth: CGFloat = 22
  let width: CGFloat = 45
  @Binding var tracking: Tracking
  @Binding var isInfoDisplayed: Bool
  
  var body: some View {
    VStack() {
      Button(action: {
        self.isInfoDisplayed.toggle()
        Feedback.selected()
      }) {
        Image(systemName: isInfoDisplayed ? "info.circle.fill" : "info.circle")
          .resizable()
          .frame(width: buttonWidth, height: buttonWidth, alignment: .center)
          .offset(y: -2)
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
    .frame(width: width, height: width*2, alignment: .center)
    .background(Color.alpha)
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .shadow(radius: 1)
  }
}

// MARK: Previews
struct MapControl_Previews: PreviewProvider {
  @State static var tracking: Tracking = .disabled
  @State static var isInfoDisplayed = false
  static var previews: some View {
    Group {
      MapControl(tracking: $tracking, isInfoDisplayed: $isInfoDisplayed)
        .environment(\.colorScheme, .light)
      MapControl(tracking: $tracking, isInfoDisplayed: $isInfoDisplayed)
        .environment(\.colorScheme, .dark)
    }
      
    .previewLayout(.fixed(width: 60, height: 100))
  }
}
