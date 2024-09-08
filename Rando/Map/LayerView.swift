//
//  InfoView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 11/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

enum Layer: String, CaseIterable, Equatable, Identifiable {
    
    case ign25, openTopoMap, ign, openStreetMap, standard, satellite, flyover, swissTopo
    
    var localized: String { self.rawValue.localized }
    
    /// Only layers we can actually download (MKTileOverlay),  (Maps currentType standard, hybrid, flyover are not  overlays)
    static var onlyOverlaysLayers: [Layer] { [.ign25, .openTopoMap, .ign, .openStreetMap, .swissTopo] }
    
    var id: Self { self }
    
}


struct LayerView: View {
    
    @Binding var isLayerDisplayed: Bool
    
    @State var isOffline: Bool = UserDefaults.isOffline
    @State private var showingChildView = false
    
    @EnvironmentObject var appManager: AppManager
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        Spacer()
                        ForEach(Layer.allCases) { layer in
                            Button {
                                appManager.selectedLayer = layer
                                Feedback.selected()
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(layer == appManager.selectedLayer ? Color.tintColor : .clear)
                                    VStack {
                                        Image(layer.rawValue).resizable().frame(width: 100, height: 100, alignment: .center).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        Text(LocalizedStringKey(layer.rawValue)).foregroundColor(Color.primary)
                                    }.padding(8)
                                }
                                
                            }
                        }
                        Spacer()
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationBarTitle(Text("map"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.isLayerDisplayed.toggle()
                Feedback.selected()
            }) {
                DismissButton()
            })
            .navigationBarItems(leading: Picker(selection: $appManager.displayedCategory, label: Text("displayOnMap")) {
                ForEach(Category.allCasesForMaps, id: \.self) { filter in
                    HStack(alignment: .center, spacing: 8) {
                        Text(LocalizedStringKey(filter.rawValue))
                        filter.icon
                    }
                }
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .frame(height: 300, alignment: .top)
        .cornerRadius(8)
        .shadow(radius: 10)
        
    }
    
}

// MARK: Preview
#Preview {
    LayerView(isLayerDisplayed: .constant(true))
}
