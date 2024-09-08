//
//  MapSettingsRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 5/24/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI


struct MapSettingsRow: View {
    
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        
            HStack(spacing: 10) {
                Label("map", systemImage: "map").lineLimit(1).minimumScaleFactor(0.5)
                Picker(selection: $appManager.selectedLayer, label: Text("")) {
                    ForEach(Layer.onlyOverlaysLayers, id: \.self) { layer in
                        Text(LocalizedStringKey(layer.rawValue))
                    }
                }
                .onChange(of: appManager.selectedLayer) { oldValue, newValue in
                    Feedback.selected()
                }
                .pickerStyle(.menu)
            }
        
    }
}

// MARK: Preview
#Preview {
    MapSettingsRow().environmentObject(AppManager.shared)
}
