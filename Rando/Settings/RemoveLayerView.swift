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
    @State var hasComputedSizes: Bool = false
    
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
                        if hasComputedSizes {
                            Text(layer.downloadedSize.toBytesString).foregroundColor(.gray)
                        } else {
                            ProgressView(value: 0)
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    }
                }
                .disabled(layer.downloadedSize == 0)
                .onAppear {
                    
                }
            }
        }
        .navigationBarTitle("DeleteLayer", displayMode: .inline)
        .actionSheet(isPresented: $showAlert) {
            return ActionSheet(
                title: Text("\("DeleteLayerMessage".localized) \(selectedLayer.localized)"),
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
    static var previews: some View {
        RemoveLayerView()
    }
}
