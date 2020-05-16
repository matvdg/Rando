//
//  InfoView.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 11/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct InfoView: View {
  
  enum DisplayMode: String, CaseIterable, Equatable {
    case IGN, Standard, Satellite, Flyover
  }
  
  @Binding var selectedDisplayMode: DisplayMode
  @Binding var isInfoDisplayed: Bool
  @State var isOffline: Bool = TileManager.shared.isOffline
  
  var body: some View {
    
    NavigationView {
      
      VStack(spacing: 20.0) {
        
        Picker(selection: $selectedDisplayMode, label: Text("")) {
          ForEach(DisplayMode.allCases, id: \.self) { mode in
            Text(mode.rawValue)
          }
        }
        .pickerStyle(SegmentedPickerStyle())
        
        Divider()
        
        Toggle(isOn: self.$isOffline) {
          Text("MapOfflineSwitcher".localized)
        }
        .onTapGesture {
          self.isOffline.toggle()
          TileManager.shared.isOffline = self.isOffline
        }
        
        NavigationLink(destination: CacheView()) {
          HStack {
            Text("ManageCache".localized)
              .foregroundColor(.text)
            Spacer()
            Image(systemName: "chevron.right")
              .foregroundColor(.gray)
          }
            
        }
        .frame(height: 30, alignment: .top)
        
        Spacer()
        
        }.padding()
      
      .navigationBarTitle(Text("MapSettings".localized), displayMode: .inline)
      .navigationBarItems(leading:
        Button(action: {
          self.isInfoDisplayed.toggle()
          Feedback.selected()
        }) {
          Image(systemName: "chevron.down")
        }
      )
    }
    .navigationViewStyle(StackNavigationViewStyle())
    .frame(maxWidth: 500)
    .frame(height: 300.0, alignment: .top)
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .shadow(radius: 10)
    .gesture(DragGesture().onEnded { value in
      if value.translation.height > 100 {
        self.isInfoDisplayed.toggle()
        Feedback.selected()
      }
    })
    
  }
  
}

// MARK: Previews
struct InfoView_Previews: PreviewProvider {
  @State static var selectedDisplayMode = InfoView.DisplayMode.IGN
  @State static var isInfoDisplayed = true
  @State static var isOffline = false
  static var previews: some View {
    Group {
      InfoView(selectedDisplayMode: $selectedDisplayMode, isInfoDisplayed: $isInfoDisplayed)
        .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
        .previewDisplayName("iPhone 11 Pro Max")
        .environment(\.colorScheme, .dark)
      InfoView(selectedDisplayMode: $selectedDisplayMode, isInfoDisplayed: $isInfoDisplayed)
        .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (3rd generation)"))
        .previewDisplayName("iPad Pro")
        .environment(\.colorScheme, .light)
      InfoView(selectedDisplayMode: $selectedDisplayMode, isInfoDisplayed: $isInfoDisplayed)
        .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
        .previewDisplayName("iPhone SE")
        .environment(\.colorScheme, .light)
    }
    
  }
}
