//
//  InfoView.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 11/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct InfoView: View {
  
  enum DisplayMode: Int, CaseIterable {
    case ign = 0, standard, satellite
    var localized: String { String(describing: self).capitalized }
  }
  
  @Binding var selectedDisplayMode: Int
  @Binding var isInfoDisplayed: Bool
  @State var isOffline: Bool = TileManager.shared.isOffline
  
  var body: some View {
    
    VStack(alignment: .leading) {
      HStack {
        Text("MapSettings".localized)
        .font(.headline)
        .multilineTextAlignment(.leading)
        Spacer()
        Button(action: {
          self.isInfoDisplayed.toggle()
        }) {
          Image(systemName: "xmark.circle.fill")
            .resizable()
            .frame(width: 25, height: 25)
            .accentColor(Color.lightgray)
            .background(Color.lightgrayInverted)
            .clipShape(Circle())
            
        }
      }
      
      Picker(selection: $selectedDisplayMode, label: Text("Mode")) {
        ForEach(0..<DisplayMode.allCases.count, id: \.self) { index in
          Text(DisplayMode.allCases[index].localized).tag(index)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
      Divider()
      VStack(alignment: .leading) {
        Toggle(isOn: $isOffline) {
          Text("MapOfflineSwitcher".localized)
        }
        .onTapGesture {
          self.isOffline.toggle()
          TileManager.shared.isOffline = self.isOffline
        }
      }
    }
    .padding()
    .frame(height: 300, alignment: .top)
    .background(Color.alpha)
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .shadow(radius: 10)
    
  }
  
}

struct InfoView_Previews: PreviewProvider {
  @State static var selectedDisplayMode = InfoView.DisplayMode.ign.rawValue
  @State static var isInfoDisplayed = true
  @State static var isOffline = false
  static var previews: some View {
    InfoView(selectedDisplayMode: $selectedDisplayMode, isInfoDisplayed: $isInfoDisplayed)
  }
}
