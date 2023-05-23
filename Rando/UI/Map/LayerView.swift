//
//  InfoView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 11/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

enum Layer: String, CaseIterable, Equatable, Identifiable {
    
    case ign25, openTopoMap, ign, openStreetMap, standard, satellite, flyover

    var localized: String { self.rawValue.localized }
    
    /// Default rawValue to actually download some tiles (Maps is not an overlay)
    var fallbackLayer: Layer {
        switch self {
        case .ign25, .flyover, .standard, .satellite:
            return .ign25
        case .ign:
            return .ign
        case .openStreetMap:
            return .openStreetMap
        case .openTopoMap:
            return .openTopoMap
        }
    }
    var id: Self { self }
}

struct LayerView: View {
    
    @Binding var selectedLayer: Layer
    @Binding var isInfoDisplayed: Bool
    @State var isOffline: Bool = UserDefaults.isOffline
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10.0) {
                
                HStack {
                    Text("MapSettings".localized)
                        .font(.system(size: 20, weight: .bold))
                    
                    Spacer()
                    Button(action: {
                        self.isInfoDisplayed.toggle()
                        Feedback.selected()
                    }) {
                        DismissButton()
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Layer.allCases) { layer in
                            Button {
                                selectedLayer = layer
                                Feedback.selected()
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous).fill(layer == selectedLayer ? .blue : .clear)
                                    VStack {
                                        Image(layer.rawValue).resizable().frame(width: 100, height: 100, alignment: .center).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        Text(layer.localized).foregroundColor(Color.primary)
                                    }.padding(8)
                                }
                                
                            }
                        }
                    }
                }
                .padding()
                
            }
            .padding()
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .frame(height: 250.0, alignment: .top)
        .cornerRadius(8)
        .shadow(radius: 10)
    }
    
}

// MARK: Previews
struct InfoView_Previews: PreviewProvider {
    @State static var selectedLayer: Layer = UserDefaults.currentLayer
    @State static var isInfoDisplayed = true
    @State static var isOffline = false
    static var previews: some View {
        Group {
            LayerView(selectedLayer: $selectedLayer, isInfoDisplayed: $isInfoDisplayed)
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
                .previewDisplayName("iPhone 11 Pro Max")
                .environment(\.colorScheme, .dark)
            LayerView(selectedLayer: $selectedLayer, isInfoDisplayed: $isInfoDisplayed)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (3rd generation)"))
                .previewDisplayName("iPad Pro")
            
                .environment(\.colorScheme, .light)
            LayerView(selectedLayer: $selectedLayer, isInfoDisplayed: $isInfoDisplayed)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE")
                .environment(\.colorScheme, .light)
        }
    }
}