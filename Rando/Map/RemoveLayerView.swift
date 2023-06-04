//
//  RemoveLayerView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 28/05/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct RemoveLayerView: View {
    
    @State private var showAlert = false
    @State var selectedLayer: Layer = .ign
    @Binding var isLayerDisplayed: Bool
    
    var body: some View {
        List {
            ForEach(Layer.onlyOverlaysLayers) { layer in
                Button {
                    selectedLayer = layer
                    showAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash").tint(.red)
                        Text(LocalizedStringKey(layer.rawValue))
                        Spacer()
                        Text(layer.downloadedSize.toBytes).foregroundColor(.gray)
                    }
                }
                .disabled(layer.downloadedSize == 0)
            }
        }
        .navigationBarTitle("DeleteLayer", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            self.isLayerDisplayed.toggle()
            Feedback.selected()
        }) {
            DismissButton()
        })
        .actionSheet(isPresented: $showAlert) {
            return ActionSheet(
                title: Text("\("DeleteLayerMessage") \(selectedLayer.rawValue)"),
                buttons: [
                    .destructive(Text("DeleteLayer"), action: {
                        Feedback.selected()
                        TileManager.shared.remove(layer: selectedLayer)
                    }),
                    .cancel(Text("Cancel"))
                ]
            )
        }
    }
}

struct RemoveLayerView_Previews: PreviewProvider {
    @State static var isLayerDisplayed: Bool = true
    static var previews: some View {
        RemoveLayerView(isLayerDisplayed: $isLayerDisplayed)
    }
}
