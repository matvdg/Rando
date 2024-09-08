//
//  RemoveLayerView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 28/05/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI


struct RemoveLayerView: View {
    
    @State private var showAlert = false
    @State var selectedLayer: Layer = .ign
    @State var sizes = [Layer:(String, Double)]()
    @ObservedObject private var tileManager = TileManager.shared
    
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
                        if let size = sizes[layer] {
                            Text(size.0).foregroundColor(.gray)
                        } else {
                            ProgressView(value: 0)
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    }
                }
                .disabled(sizes[layer] == nil || sizes[layer]?.1 == 0)
                .onAppear {
                    refreshSizes()
                }
                .onChange(of: tileManager.hasRemovedLayerTiles) {
                    refreshSizes()
                }
            }
        }
        .navigationBarTitle("deleteLayer", displayMode: .inline)
        .actionSheet(isPresented: $showAlert) {
            return ActionSheet(
                title: Text("\("deleteLayerMessage".localized) \(selectedLayer.localized)"),
                buttons: [
                    .destructive(Text("deleteLayer"), action: {
                        Feedback.selected()
                        tileManager.remove(layer: selectedLayer)
                    }),
                    .cancel(Text("cancel"))
                ]
            )
        }
    }
    
    private func refreshSizes() {
        DispatchQueue.global(qos: .userInteractive).async {
            Layer.onlyOverlaysLayers.forEach {
                let size = tileManager.getDownloadedSize(layer: $0)
                sizes[$0] = (size.toBytesString, size)
            }
        }
    }
}

#Preview {
    RemoveLayerView()
}
