//
//  InfoView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 11/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
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
    
    enum PoiFilter: String, CaseIterable {
        case none, all, refuge, peak, waterfall, sheld
        var localized: String { rawValue }
        var icon: Image {
            switch self {
            case .none: return Image(systemName: "eye.slash")
            case .all: return Image(systemName: "infinity")
            case .refuge: return Image(systemName: "house.lodge.fill")
            case .peak: return Image(systemName: "mountain.2")
            case .waterfall: return Image(systemName: "camera")
            case .sheld: return Image(systemName: "house")
            }
        }
    }
    
    @Binding var selectedLayer: Layer
    @Binding var isLayerDisplayed: Bool
    @State var isOffline: Bool = UserDefaults.isOffline
    @State private var showingChildView = false
    @Binding var filter: PoiFilter
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        Spacer()
                        ForEach(Layer.allCases) { layer in
                            Button {
                                selectedLayer = layer
                                Feedback.selected()
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(layer == selectedLayer ? Color.tintColor : .clear)
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
            .navigationBarTitle(Text("Map"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.isLayerDisplayed.toggle()
                Feedback.selected()
            }) {
                DismissButton()
            })
            .navigationBarItems(leading: Picker(selection: $filter, label: Text("")) {
                ForEach(PoiFilter.allCases, id: \.self) { filter in
                    HStack(alignment: .center, spacing: 8) {
                        Text(LocalizedStringKey(filter.rawValue))
                        filter.icon
                    }
                }
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .frame(height: 250.0, alignment: .top)
        .cornerRadius(8)
        .shadow(radius: 10)
        
    }
    
}

// MARK: Previews
struct LayerView_Previews: PreviewProvider {
    @State static var selectedLayer: Layer = UserDefaults.currentLayer
    @State static var isInfoDisplayed = true
    @State static var isOffline = false
    @State static var filter: LayerView.PoiFilter = .none
    static var previews: some View {
        Group {
            LayerView(selectedLayer: $selectedLayer, isLayerDisplayed: $isInfoDisplayed, filter: $filter)
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
                .previewDisplayName("iPhone 11 Pro Max")
                .environment(\.colorScheme, .dark)
            LayerView(selectedLayer: $selectedLayer, isLayerDisplayed: $isInfoDisplayed, filter: $filter)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (3rd generation)"))
                .previewDisplayName("iPad Pro")
            
                .environment(\.colorScheme, .light)
            LayerView(selectedLayer: $selectedLayer, isLayerDisplayed: $isInfoDisplayed, filter: $filter)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE")
                .environment(\.colorScheme, .light)
        }
    }
}
