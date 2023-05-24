//
//  MapSettingsRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 5/24/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct MapSettingsRow: View {
    
    @Binding var selectedLayer: Layer

    var body: some View {
        
            HStack(spacing: 10) {
                Image(systemName: "map").foregroundColor(.tintColorTabBar)
                Text("MapSettings".localized)
                    .font(.headline)
                    .foregroundColor(.tintColorTabBar)
                Picker(selection: $selectedLayer, label: Text("")) {
                    ForEach(Layer.onlyOverlaysLayers, id: \.self) { layer in
                        Text(layer.localized)
                    }
                }
                
                .onChange(of: selectedLayer) { newValue in
                    UserDefaults.currentLayer = newValue
                }
                .pickerStyle(.menu)
            }
        
    }
}

// MARK: Previews
struct MapSettingsRow_Previews: PreviewProvider {
    
    @State static var selectedLayer: Layer = .ign25

    static var previews: some View {
        MapSettingsRow(selectedLayer: $selectedLayer)
            .previewLayout(.fixed(width: 300, height: 80))
            .environment(\.colorScheme, .light)
    }
}
