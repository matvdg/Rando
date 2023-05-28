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
    
    var body: some View {
        List {
            ForEach(Layer.onlyOverlaysLayers) { layer in
                Button {
                    selectedLayer = layer
                    showAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash").tint(.red)
                        Text(layer.localized)
                        Spacer()
                        Text(layer.downloadedSize.toBytes).foregroundColor(.gray)
                    }
                }
                .disabled(layer.downloadedSize == 0)
            }
        }
        .navigationBarTitle("DeleteLayer".localized, displayMode: .inline)
        .actionSheet(isPresented: $showAlert) {
            return ActionSheet(
                title: Text("\("DeleteLayerMessage".localized) \(selectedLayer.localized)"),
                buttons: [
                    .destructive(Text("DeleteLayer".localized), action: {
                        TileManager.shared.remove(layer: selectedLayer)
                    }),
                    .cancel(Text("Cancel".localized))
                ]
            )
        }
    }
}

struct RemoveLayerView_Previews: PreviewProvider {
    static var previews: some View {
        RemoveLayerView()
    }
}
