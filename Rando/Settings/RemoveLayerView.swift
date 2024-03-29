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
    @State var sizes = [Layer:(String, Double)]()
    
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
                    DispatchQueue.global(qos: .background).async {
                        Layer.onlyOverlaysLayers.forEach {
                            let size = TileManager.shared.getDownloadedSize(layer: $0)
                            sizes[$0] = (size.toBytesString, size)
                        }
                    }
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
