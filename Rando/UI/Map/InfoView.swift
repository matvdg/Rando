//
//  InfoView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 11/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

enum Layer: String, CaseIterable, Equatable, Identifiable {
    
    case ign25, ign, standard, satellite, flyover, openStreetMap, openTopoMap
    var localized: String { self.rawValue.localized }
    var id: Self { self }
}

struct InfoView: View {
    
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
        .frame(maxWidth: 500)
        .frame(height: 250.0, alignment: .top)
        .cornerRadius(8)
        .shadow(radius: 10)
    }
    
}

// MARK: Previews
struct InfoView_Previews: PreviewProvider {
    @State static var selectedLayer: Layer = .ign25
    @State static var isInfoDisplayed = true
    @State static var isOffline = false
    static var previews: some View {
        Group {
            InfoView(selectedLayer: $selectedLayer, isInfoDisplayed: $isInfoDisplayed)
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
                .previewDisplayName("iPhone 11 Pro Max")
                .environment(\.colorScheme, .dark)
            InfoView(selectedLayer: $selectedLayer, isInfoDisplayed: $isInfoDisplayed)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (3rd generation)"))
                .previewDisplayName("iPad Pro")
            
                .environment(\.colorScheme, .light)
            InfoView(selectedLayer: $selectedLayer, isInfoDisplayed: $isInfoDisplayed)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE")
                .environment(\.colorScheme, .light)
        }
    }
}
